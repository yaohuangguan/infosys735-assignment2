#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGION="${AWS_REGION:-us-east-1}"
STACK="${STACK_NAME:-anygroupllc-a2}"
WAIT_SECONDS="${FORECAST_WAIT_SECONDS:-90}"
fail() { echo "FAIL: $*" >&2; exit 1; }
info() { printf '\n== %s ==\n' "$*"; }

for tool in aws python3 curl; do command -v "$tool" >/dev/null || fail "$tool unavailable"; done
aws sts get-caller-identity --region "$REGION" --query Account --output text >/dev/null \
  || fail "Expired/missing AWS credentials: restart Learner Lab and refresh local CLI credentials"

info "CloudFormation"
STATUS=$(aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" \
  --query 'Stacks[0].StackStatus' --output text)
case "$STATUS" in CREATE_COMPLETE|UPDATE_COMPLETE) echo "PASS: $STACK ($STATUS)";; *) fail "Stack not ready: $STATUS";; esac
OUTPUTS=$(aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" \
  --query 'Stacks[0].Outputs' --output json)
get_output() {
  python3 -c 'import json,sys;print(next((x["OutputValue"] for x in json.loads(sys.argv[1]) if x["OutputKey"]==sys.argv[2]),""))' "$OUTPUTS" "$1"
}
VPC=$(get_output VpcId)
ALB=$(get_output PublicAlbDns)
BUCKET=$(get_output ForecastBucket)
TOPIC=$(get_output AlarmTopicArn)
[[ -n "$ALB" && -n "$BUCKET" && -n "$TOPIC" ]] || fail "CloudFormation outputs incomplete"

info "Load-balancer target health"
check_targets() {
  local name="$1" arn states
  arn=$(aws elbv2 describe-target-groups --region "$REGION" --names "$name" \
    --query 'TargetGroups[0].TargetGroupArn' --output text)
  states=$(aws elbv2 describe-target-health --region "$REGION" --target-group-arn "$arn" \
    --query 'TargetHealthDescriptions[].{Id:Target.Id,State:TargetHealth.State}' --output json)
  python3 -c '
import json,sys
items=json.loads(sys.argv[1]); name=sys.argv[2]
assert len(items)>=2, f"{name}: expected at least 2 targets; got {len(items)}"
assert all(x["State"]=="healthy" for x in items), f"{name}: unhealthy target(s): {items}"
print(f"PASS: {name} ({len(items)} healthy targets)")
' "$states" "$name" || fail "$name target check failed"
}
check_targets anygroup-front-tg
check_targets anygroup-back-tg

info "Auto Scaling / cross-AZ placement"
ASG_JSON=$(aws autoscaling describe-auto-scaling-groups --region "$REGION" \
  --auto-scaling-group-names anygroup-frontend-asg anygroup-backend-asg \
  --query 'AutoScalingGroups[].{Name:AutoScalingGroupName,Instances:Instances[].{Id:InstanceId,AZ:AvailabilityZone,Health:HealthStatus,State:LifecycleState}}' --output json)
python3 -c '
import json,sys
groups=json.loads(sys.argv[1])
expected={"anygroup-frontend-asg","anygroup-backend-asg"}
assert {g["Name"] for g in groups}==expected, "Expected two application ASGs"
for group in groups:
    name=group["Name"]
    active=[i for i in group["Instances"] if i["State"]=="InService" and i["Health"]=="Healthy"]
    assert len(active)>=2, f"{name}: fewer than 2 healthy in-service targets"
    assert len({i["AZ"] for i in active})>=2, f"{name}: not distributed across 2 AZs"
    print(f"PASS: {name} has {len(active)} healthy instances across 2 AZs")
' "$ASG_JSON" || fail "ASG or AZ check failed"

info "Public NACL and NAT resource configuration"
NACL_JSON=$(aws ec2 describe-network-acls --region "$REGION" \
  --filters "Name=vpc-id,Values=$VPC" "Name=tag:Name,Values=public-nacl" \
  --query 'NetworkAcls[0]' --output json)
python3 -c '
import json,sys
acl=json.loads(sys.argv[1])
assert acl and acl.get("NetworkAclId"), "Public NACL not found"
rules=acl["Entries"]
assert any(
    not r["Egress"] and r["Protocol"]=="6" and r["RuleAction"]=="allow"
    and r["CidrBlock"]=="10.0.0.0/16"
    and r.get("PortRange",{}).get("From")<=443<=r.get("PortRange",{}).get("To")
    for r in rules if r.get("PortRange")
), "Public NACL does not allow inbound HTTPS from app VPC to NAT"
print("PASS: inbound TCP 443 is allowed from VPC on public NACL")
' "$NACL_JSON" || fail "NACL check failed"
NAT_JSON=$(aws ec2 describe-nat-gateways --region "$REGION" \
  --filter "Name=vpc-id,Values=$VPC" \
  --query 'NatGateways[].{State:State,Subnet:SubnetId}' --output json)
python3 -c '
import json,sys
nats=[n for n in json.loads(sys.argv[1]) if n["State"]=="available"]
assert len(nats)==2, f"Expected 2 available NATs, got {len(nats)}"
assert len({n["Subnet"] for n in nats})==2, "NATs share one subnet"
print("PASS: 2 available NAT gateways in separate subnets")
' "$NAT_JSON" || fail "NAT verification failed"

info "HTTP application chain"
check_http() {
  local path="$1" expected="$2" body
  body=$(curl -fsS --max-time 15 --retry 2 --retry-delay 2 "http://$ALB$path") \
    || fail "HTTP $path unavailable"
  if [[ "$path" == "/" ]]; then
    [[ "$body" == *"$expected"* ]] || fail "Home page missing expected content"
  else
    python3 -c '
import json,sys
obj=json.loads(sys.argv[1])
assert obj.get("service")==sys.argv[2], f"Unexpected HTTP response: {obj}"
' "$body" "$expected" || fail "$path did not reach expected service"
  fi
  echo "PASS: $path"
}
check_http / "AnyGroupLLC New Zealand"
check_http /api/ backend-app-tier
check_http /api/db/ dummy-oracle-tier

info "S3 Lambda forecast: new input -> unique new output"
input_key="forecast-input/verify-$(date -u +%Y%m%dT%H%M%S)-$$.csv"
output_key="forecast-output/runs/${input_key#forecast-input/}.json"
aws s3 cp "$DIR/sample-sales.csv" "s3://$BUCKET/$input_key" --region "$REGION" >/dev/null \
  || fail "CSV upload failed"
echo "Input: $input_key"
result=""
attempts=$(( (WAIT_SECONDS+2)/3 ))
for ((i=1; i<=attempts; i++)); do
  if result=$(aws s3 cp "s3://$BUCKET/$output_key" - --region "$REGION" 2>/dev/null); then break; fi
  sleep 3
done
[[ -n "$result" ]] || fail "No matching forecast output within ${WAIT_SECONDS}s"
python3 -c '
import csv,json,math,sys
r=json.loads(sys.argv[1]); key=sys.argv[2]
assert r["source_key"]==key, "Result is stale or from a different input"
with open(sys.argv[3],newline="",encoding="utf-8") as f:
    sales=[float(row["sales"]) for row in csv.DictReader(f)]
expected=round(sum(sales[-7:])/len(sales[-7:]),2)
assert math.isclose(r["next_day_sales_forecast"],expected,abs_tol=0.001), "Incorrect forecast"
assert r["window_size"]==min(7,len(sales)), "Wrong forecasting window"
print("PASS: newly generated forecast:",r["next_day_sales_forecast"])
' "$result" "$input_key" "$DIR/sample-sales.csv" || fail "Forecast validation failed"

info "CloudWatch/SNS configuration"
ALARM_JSON=$(aws cloudwatch describe-alarms --region "$REGION" \
  --alarm-names anygroup-frontend-high-cpu --query 'MetricAlarms[0]' --output json)
python3 -c '
import json,sys
a=json.loads(sys.argv[1]);topic=sys.argv[2]
assert a and a.get("Period")==300 and a.get("EvaluationPeriods")==2, "Alarm period not aligned with basic monitoring"
assert a["Threshold"]==70 and topic in a.get("AlarmActions",[]), "Alarm SNS action missing"
print("PASS: 70% CPU for 2 x 5-min periods; current state:",a["StateValue"])
' "$ALARM_JSON" "$TOPIC" || fail "CloudWatch config invalid"
SUBS=$(aws sns list-subscriptions-by-topic --region "$REGION" --topic-arn "$TOPIC" \
  --query 'Subscriptions[].SubscriptionArn' --output json)
python3 -c '
import json,sys
active=[s for s in json.loads(sys.argv[1]) if s not in ("PendingConfirmation","Deleted")]
print("SNS confirmed subscribers:",len(active))
if not active: print("WARNING: No confirmed SNS subscriber; email delivery not demonstrated")
if sys.argv[2]=="1" and not active: sys.exit(1)
' "$SUBS" "${REQUIRE_SNS_DELIVERY:-0}" || fail "SNS subscriber missing"

echo "PASS: automated checks finished"
echo "NOTE: private-AZ outbound HTTPS, scale-out, and actual notification delivery need separate live demonstration."
