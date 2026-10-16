# AnyGroupLLC — 15-minute Presentation Script (English)

> **Version:** 16 October 2026. **Speakers:** Vincent (Part 1), Zack (Part 2), Sam (Part 3), Kevin (Part 4). **Final length target:** 15:00. The final architecture PDF/slides accompany the video. The Console evidence in this script is a **future shot plan** — not a statement that the deleted Lab stack is currently online.

**How to read this:** Each numbered shot has an absolute final-video timestamp, the intended screen, a 10–20 second hold, and an English voiceover draft. Speakers should record their own audio after receiving the Console clips; adjust delivery pace while preserving the claims. The narration has not yet been synchronized against real footage.

## Part 1 — Vincent: Architecture & Solution Improvement (00:00–03:00)

### Shot 1.1 — 00:00–00:20 (20s, SLIDE)

**Screen:** Title slide — AnyGroupLLC / team

**English voiceover:**

> Good afternoon. We are presenting our AnyGroupLLC cloud architecture proposal and its AWS Learner Lab implementation. Our objective was to make the earlier design demonstrable, explain its technical trade-offs, and show how the infrastructure can support the company's business priorities.

### Shot 1.2 — 00:20–00:45 (25s, SLIDE)

**Screen:** Business goals / stakeholder slide

**English voiceover:**

> The CTO needs reliable e-commerce during seasonal demand, the security team needs isolation and controlled access, the IT team needs more automation, and the CFO needs cost visibility and sales insight. We therefore assess the solution on availability, security, operational efficiency, and a small forecasting extension.

### Shot 1.3 — 00:45–01:10 (25s, SLIDE)

**Screen:** Final architecture diagram, INCLUDING S3 → Lambda → S3

**English voiceover:**

> Our production direction retains the Assignment One design: a public application load balancer, a Linux frontend tier, an internal load balancer, a Windows .NET backend, and an Oracle database. The separate S3 and Lambda workflow is an additional business feature, not a replacement for the transactional database.

### Shot 1.4 — 01:10–01:35 (25s, SLIDE)

**Screen:** Production vs Learner Lab / provisional sizing

**English voiceover:**

> Following our instructor's feedback, the production starting assumptions are t3.medium for each of two Linux frontend servers, m6i.xlarge for four Windows backend servers, and db.m6i.2xlarge for Oracle with a two-terabyte storage starting point. These are untested migration estimates. The Learner Lab instead uses much smaller simulated instances.

### Shot 1.5 — 01:35–02:00 (25s, CONSOLE)

**Screen:** CloudFormation → Stacks → anygroupllc-a2 → Stack info

**English voiceover:**

> Here is the actual CloudFormation stack in the AWS Academy environment. We use Infrastructure as Code rather than manually recreating dozens of AWS resources. Once the stack has reached a complete state, the console provides a consistent inventory of the services behind our prototype.

### Shot 1.6 — 02:00–02:25 (25s, CONSOLE)

**Screen:** CloudFormation → Resources (slow scroll)

**English voiceover:**

> The Resources tab connects the architecture diagram to real services: networking and NAT gateways, public and internal load balancing, the two Auto Scaling Groups, the forecast bucket and Lambda function, plus CloudWatch and SNS. Their presence is implementation evidence, although health and data flow need separate verification.

### Shot 1.7 — 02:25–02:45 (20s, CONSOLE)

**Screen:** CloudFormation → Outputs

**English voiceover:**

> The Outputs tab exposes the deployed VPC identifier, public load balancer address, and forecast bucket. We deliberately use the current outputs rather than a hard-coded hostname, because temporary Learner Lab environments can be destroyed and recreated.

### Shot 1.8 — 02:45–03:00 (15s, SLIDE)

**Screen:** GP1 concept → GP2 evidence / handoff

**English voiceover:**

> The key improvement is not simply adding AWS product names. It is turning the proposed design into repeatable resources and testable behavior. Zack will now explain how the network separation and security boundaries work.

---

## Part 2 — Zack: Networking & Security (03:00–07:00)

### Shot 2.1 — 03:00–03:30 (30s, CONSOLE)

**Screen:** VPC → Your VPCs → anygroupllc-a2-vpc

**English voiceover:**

> The solution starts with one dedicated VPC using the address range 10.0.0.0 slash 16. It is divided into public, application, and database tiers across two Availability Zones. This creates separate network boundaries for components with different exposure and access requirements.

### Shot 2.2 — 03:30–04:00 (30s, CONSOLE)

**Screen:** VPC → Subnets → filter project VPC

**English voiceover:**

> These six subnets show the two-zone layout. Each zone contains one public subnet, one private application subnet, and one private database subnet. This allows the application instances to be distributed across zones while keeping the simulated database endpoint out of the internet-facing tier.

### Shot 2.3 — 04:00–04:30 (30s, CONSOLE)

**Screen:** VPC → Route tables → public-rt → Routes

**English voiceover:**

> The public route table has a default route to an Internet Gateway. That is appropriate for the internet-facing load balancer and NAT gateways. It does not imply that application or database instances are public; those tiers use different subnets, route tables, and Security Groups.

### Shot 2.4 — 04:30–05:00 (30s, CONSOLE)

**Screen:** VPC → Route tables → app-rt-a and app-rt-b

**English voiceover:**

> The two application subnets route their outbound traffic through separate NAT gateways, one in each Availability Zone. Private instances can therefore reach necessary external services without requiring public IP addresses. We use distinct routes so one zone is not dependent on the other zone's NAT gateway.

### Shot 2.5 — 05:00–05:30 (30s, CONSOLE)

**Screen:** VPC → Route tables → db-rt-local-only → Routes

**English voiceover:**

> The database route table is deliberately different: it has the VPC-local route but no default path to the internet. The only database service in this lab is a private dummy EC2 instance, not Oracle RDS. The route boundary helps demonstrate isolation, but by itself does not prove PCI compliance.

### Shot 2.6 — 05:30–06:00 (30s, CONSOLE)

**Screen:** VPC → NAT Gateways → nat-a / nat-b

**English voiceover:**

> Here are the two NAT gateways. Having a gateway in each Availability Zone removes a cross-zone dependency for normal application egress. NAT gateways also have running costs, so this pattern is justified by availability goals in the prototype and must be evaluated against real production usage.

### Shot 2.7 — 06:00–06:30 (30s, CONSOLE)

**Screen:** EC2 → Security Groups → inbound rules (Public ALB → Frontend → Internal ALB → Backend → DB)

**English voiceover:**

> Security Groups reinforce the network boundary by restricting inbound connections to the previous authorized tier. The public ALB receives HTTP, the frontend accepts traffic from that ALB, the backend receives traffic through the internal ALB, and the dummy database accepts port 8080 only from the backend Security Group.

### Shot 2.8 — 06:30–07:00 (30s, CONSOLE)

**Screen:** VPC → Network ACLs → public-nacl → inbound rules

**English voiceover:**

> We also corrected the public subnet network ACL so inbound HTTPS-related traffic from the VPC can pass through NAT. The console shows the configured rule. A true end-to-end test from private instances in both zones would still be needed to claim that external HTTPS connectivity works in every case.

---

## Part 3 — Sam: Reliability & Operational Excellence (07:00–11:00)

### Shot 3.1 — 07:00–07:25 (25s, CONSOLE)

**Screen:** EC2 → Load Balancers → public and internal ALBs

**English voiceover:**

> Now we move from network controls to reliability. Two Application Load Balancers have distinct responsibilities. The public ALB handles external entry to the frontend tier. The internal ALB routes frontend API requests to backend instances without making the backend directly internet-facing.

### Shot 3.2 — 07:25–07:55 (30s, CONSOLE)

**Screen:** EC2 → Target Groups → anygroup-front-tg → Targets

**English voiceover:**

> The frontend target group should show two healthy application instances. An ALB health check determines whether an instance is eligible to receive requests. This is important because merely creating EC2 servers would not give us evidence that the application is actually reachable and responding correctly.

### Shot 3.3 — 07:55–08:25 (30s, CONSOLE)

**Screen:** EC2 → Target Groups → anygroup-back-tg → Targets

**English voiceover:**

> We apply the same health-based approach to the backend. The internal ALB sends traffic only to the healthy backend targets. Both target groups are configured to call the health endpoint and expect a successful response. This provides basic request-level resilience, although a real failure injection is still separate work.

### Shot 3.4 — 08:25–08:55 (30s, CONSOLE)

**Screen:** EC2 → Auto Scaling Groups → anygroup-frontend-asg → Details / Instance management

**English voiceover:**

> The frontend Auto Scaling Group has a minimum and desired capacity of two instances, with a maximum of four. Its instances are placed in two Availability Zones. Auto Scaling can replace an unhealthy instance and adjust capacity when policies require it, reducing routine manual intervention for a small IT team.

### Shot 3.5 — 08:55–09:25 (30s, CONSOLE)

**Screen:** EC2 → Auto Scaling Groups → anygroup-backend-asg → Details / Instance management

**English voiceover:**

> The backend Auto Scaling Group uses the same baseline size and maximum capacity. This is a lab-sized architecture, not the proposed Windows production fleet. Its cross-zone distribution and attached target group can be inspected directly here, while measured failover time and recovery objectives still require testing.

### Shot 3.6 — 09:25–09:50 (25s, CONSOLE)

**Screen:** Auto Scaling Group → Automatic scaling → CPU target tracking

**English voiceover:**

> For variable traffic, both groups use a CPU target-tracking policy set at sixty percent. This is a scaling target, not an assertion that a load test has already triggered additional instances. Separately, a CloudWatch alarm observes frontend CPU over two five-minute periods.

### Shot 3.7 — 09:50–10:10 (20s, CONSOLE)

**Screen:** Browser → current PublicAlbDns → /

**English voiceover:**

> Let's verify the complete request path with actual responses. The root URL is reached through the public ALB and returns the frontend's AnyGroupLLC prototype page. This is stronger evidence than a list of deployed resources alone.

### Shot 3.8 — 10:10–10:30 (20s, CONSOLE)

**Screen:** Browser → current PublicAlbDns → /api/

**English voiceover:**

> The API URL travels from the public ALB into the frontend, then across the internal load balancer to the backend tier. The response identifies the backend service, which supports our claim that the internal application routing is functional.

### Shot 3.9 — 10:30–11:00 (30s, CONSOLE)

**Screen:** Browser → current PublicAlbDns → /api/db/

**English voiceover:**

> The database path adds one more hop, from the backend to the private dummy database service on port 8080. A successful response demonstrates the intended multi-tier connectivity. It does not represent an actual Oracle migration, proven database failover, or production transaction processing. That distinction matters in our evaluation.

---

## Part 4 — Kevin: Forecasting & Business Value (11:00–15:00)

### Shot 4.1 — 11:00–11:20 (20s, SLIDE)

**Screen:** Sales forecast data flow: S3 → Lambda → S3

**English voiceover:**

> Our additional feature responds to the CFO's forecasting requirement. Rather than claim to have a production machine-learning model, we built a small event-driven pipeline that demonstrates how new sales data can trigger automated processing with minimal application-server management.

### Shot 4.2 — 11:20–11:45 (25s, CONSOLE)

**Screen:** S3 → Bucket from ForecastBucket output → forecast-input/

**English voiceover:**

> We use a private, encrypted S3 bucket. The forecast-input prefix is reserved for incoming daily-sales CSV files, while forecast-output stores processing results. Separating prefixes prevents the output file from triggering the same Lambda function repeatedly.

### Shot 4.3 — 11:45–12:20 (35s, CONSOLE)

**Screen:** S3 → forecast-input/ → Upload → upload unique CSV

**English voiceover:**

> Here we upload a CSV with dated, non-negative sales observations. The S3 object-created event initiates the processing workflow. For evidence, the input filename needs to be unique to this recording, so the matching output is clearly new rather than an old result left in the bucket.

### Shot 4.4 — 12:20–12:50 (30s, CONSOLE)

**Screen:** Lambda → Functions → anygroup-sales-forecast → Configuration / Triggers

**English voiceover:**

> The new object triggers the Python 3.12 Lambda function. It decodes the S3 object key, checks that dates are consecutive, rejects invalid numerical values, and calculates an arithmetic average of the most recent seven daily sales observations. Invalid data causes an error rather than a misleading prediction.

### Shot 4.5 — 12:50–13:20 (30s, CONSOLE)

**Screen:** S3 → forecast-output/runs/<filename>.json → Open / Download

**English voiceover:**

> Each successful run produces its own JSON result under the runs prefix. That is especially important for verification: a matching source key proves we are seeing output for the input just uploaded, not merely reopening the latest file from a previous invocation.

### Shot 4.6 — 13:20–13:50 (30s, CONSOLE)

**Screen:** View JSON → source_key, next_day_sales_forecast, window_size

**English voiceover:**

> The result records the source CSV, observation window, forecast date, and predicted daily sales. With our committed demonstration sample, the last seven values average to five hundred fifty-nine point seven one. This proves the calculation executes; it does not establish predictive accuracy under real promotions, returns, or stockouts.

### Shot 4.7 — 13:50–14:15 (25s, CONSOLE)

**Screen:** CloudWatch → Alarms → anygroup-frontend-high-cpu

**English voiceover:**

> For operational visibility, CloudWatch includes a frontend CPU alarm with a seventy-percent threshold over two five-minute periods. It is intentionally aligned with EC2 basic monitoring to avoid unnecessary detailed-monitoring cost in a small teaching account. This demonstrates the configuration, not guaranteed notification delivery.

### Shot 4.8 — 14:15–14:35 (20s, CONSOLE)

**Screen:** SNS → Topics → anygroup-infrastructure-alarms → Subscriptions

**English voiceover:**

> The alarm actions reference an SNS topic. Email subscriptions are optional and require explicit confirmation. If there is no confirmed subscriber, we report the topic configuration only; we do not claim that an email notification was delivered.

### Shot 4.9 — 14:35–15:00 (25s, SLIDE)

**Screen:** Business value, limitations and recommendation / team credits

**English voiceover:**

> In summary, the prototype demonstrates repeatable cloud resources, network isolation, health-checked application tiers, and a practical sales-data extension. Production still requires workload testing, Oracle licensing and compatibility checks, recovery exercises, and payment-security assessment. Our recommendation is to retain the architecture direction while addressing those validation gates before launch.

---

## Before making factual claims

- Stop recording when any target is unhealthy, the CloudFormation stack is incomplete, or the S3 result does not correspond to the freshly uploaded input.
- In the current known state, **`anygroupllc-a2` was deleted**; a fresh paid Lab deployment is required for live evidence. Obtain account budget/authorization before creating it.
- Don't call the simulated EC2 endpoint a real Oracle RDS database; don't call HTTP an HTTPS deployment; don't claim failover, scale-out, private-AZ outbound connectivity, SNS delivery or forecast accuracy without independent evidence.
- The teacher's instruction is to spend a substantial share of the video on **working AWS Management Console services**. The title/architecture/closing slides are intentionally short.
