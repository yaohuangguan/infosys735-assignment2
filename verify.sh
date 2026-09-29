#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
R=us-east-1
STACK=anygroupllc-a2

echo "== stack =="
aws cloudformation describe-stacks --region "$R" --stack-name "$STACK" --query 'Stacks[0].StackStatus' --output text

echo "== outputs =="
aws cloudformation describe-stacks --region "$R" --stack-name "$STACK" --query 'Stacks[0].Outputs[].{Key:OutputKey,Value:OutputValue}' --output table

FRONT_TG=$(aws elbv2 describe-target-groups --region "$R" --names anygroup-front-tg --query 'TargetGroups[0].TargetGroupArn' --output text)
BACK_TG=$(aws elbv2 describe-target-groups --region "$R" --names anygroup-back-tg --query 'TargetGroups[0].TargetGroupArn' --output text)
ALB=$(aws elbv2 describe-load-balancers --region "$R" --names anygroup-public-alb --query 'LoadBalancers[0].DNSName' --output text)
BUCKET=$(aws cloudformation describe-stacks --region "$R" --stack-name "$STACK" --query 'Stacks[0].Outputs[?OutputKey==`ForecastBucket`].OutputValue' --output text)

echo "== frontend targets =="
aws elbv2 describe-target-health --region "$R" --target-group-arn "$FRONT_TG" --query 'TargetHealthDescriptions[].{Id:Target.Id,State:TargetHealth.State,Reason:TargetHealth.Reason}' --output table

echo "== backend targets =="
aws elbv2 describe-target-health --region "$R" --target-group-arn "$BACK_TG" --query 'TargetHealthDescriptions[].{Id:Target.Id,State:TargetHealth.State,Reason:TargetHealth.Reason}' --output table

echo "== ASG placement =="
aws autoscaling describe-auto-scaling-groups --region "$R" --auto-scaling-group-names anygroup-frontend-asg anygroup-backend-asg --query 'AutoScalingGroups[].{Name:AutoScalingGroupName,Desired:DesiredCapacity,Instances:Instances[].{Id:InstanceId,AZ:AvailabilityZone,Health:HealthStatus,State:LifecycleState}}' --output json

echo "== HTTP root =="
curl -fsS --max-time 10 "http://$ALB/" | head -n 20

echo "== HTTP backend =="
curl -fsS --max-time 10 "http://$ALB/api/" | head -n 5

echo "== HTTP db chain =="
curl -fsS --max-time 10 "http://$ALB/api/db/" | head -n 5

echo "== forecast upload =="
aws s3 cp /home/samyao/work/infosys735-assignment2/sample-sales.csv "s3://$BUCKET/forecast-input/sample-sales.csv" --region "$R"
sleep 8
echo "== forecast result =="
aws s3 cp "s3://$BUCKET/forecast-output/latest.json" - --region "$R"

echo "== alarm =="
aws cloudwatch describe-alarms --region "$R" --alarm-names anygroup-frontend-high-cpu --query 'MetricAlarms[0].{State:StateValue,Metric:MetricName,Namespace:Namespace,Actions:AlarmActions}' --output json
