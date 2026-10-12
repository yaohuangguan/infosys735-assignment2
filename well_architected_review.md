# Well-Architected Review

This review explains how the Assignment 1 production design was checked and improved for Assignment 2. The deployed prototype is intentionally smaller than the production design, but it preserves the core cloud architecture controls that matter for the pitch and AWS Console demonstration.

## Selected pillars

The main two pillars for detailed discussion are:

1. **Reliability** — the case requires availability and scalability during launch and seasonal promotions.
2. **Operational Excellence** — the IT Manager has a small 15-person team and wants less manual firefighting.

Two further pillars are included for a more rounded review:

3. **Security** — the CISO is concerned about DDoS, PCI duties, and high-value data extraction.
4. **Cost Optimization** — the CFO wants better IT cost control and an operating expenditure model.

## Production baseline from Assignment 1

The Assignment 1 design uses:

- Route 53 and CloudFront for external entry and content delivery.
- AWS WAF and Shield as edge protection.
- A public Application Load Balancer for application traffic.
- A frontend Auto Scaling Group for Apache/Linux.
- An internal Application Load Balancer for backend routing.
- A backend Auto Scaling Group for .NET Core/Windows.
- RDS for Oracle Multi-AZ for the database tier.
- Private S3 catalogue image storage with global delivery through CloudFront.
- A VPC with two Availability Zones and separate public, application, and database subnets.

## Responding to Assignment 1 feedback: instance sizing

The Assignment 1 instructor feedback (Yi-Chien Vita Tsai, 12 October 2026) asked for **provisional EC2 instance types per application tier and an initial RDS class**. This is a design-document improvement, not a new Learner Lab deployment.

| Production tier | Initial class | Proposed availability pattern | Why this is a starting hypothesis |
| --- | --- | --- | --- |
| Apache/Linux frontend | `t3.medium` (2 vCPU / 4 GiB) | Two instances, two AZs, public ALB | Cost-conscious for variable traffic; measure CPU credits under sustained load |
| .NET Core/Windows backend | `m6i.xlarge` (4 vCPU / 16 GiB) | **Four** instances, two AZs, internal ALB | Respects the existing four-host / 16-GB-per-host estate; physical CPU is not directly equivalent to vCPU |
| RDS for Oracle 19c | `db.m6i.2xlarge` (8 vCPU / 32 GiB; initial ~2-TB storage target) | Multi-AZ DB deployment | Closer to the existing Oracle server's 32-GB memory and 2-TB storage; validate edition, licensing, regional availability and IOPS |

The actual lab retains `t3.micro` Linux/Python dummy app instances and one `t3.micro` dummy DB EC2. **It does not deploy Oracle RDS or the proposed production-sized instances.** Confirm `ap-southeast-6` service/class availability, test CPU, memory, peak response time, T3 credits, Oracle capacity, restore and failover, and compare all-in licensing/network costs before production. This addresses a specific instructor suggestion without changing a previously accepted architecture.

RDS reference: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Oracle.Concepts.InstanceClasses.html

## GP1 baseline versus GP2 demonstrated improvements

A component **already proposed in GP1** is not itself a new GP2 design improvement. The improvement lies in making the design testable, automated and better justified. Evidence should be refreshed in the live Learner Lab.

| AWS Well-Architected practice | GP1 baseline | GP2 gap and change | Demo evidence | Remaining validation |
| --- | --- | --- | --- | --- |
| Reliability - automatically recover from failure | Two AZs, public/internal ALBs and ASGs already proposed | Implement ASGs + ELB health checks in CloudFormation; add health assertions to `verify.sh` | Target health, cross-AZ in-service instances, HTTP proxy chain | Actual failure injection, AZ survival, database failover / RTO-RPO |
| Operational Excellence - operations as code / learn from failures | Manual workload/ops risks identified | Repeatable CloudFormation deploy/verify/teardown; remove failed `dnf install httpd` startup dependency; test forecasts offline | Stack resources, scripts and explicit pass/fail checks | Production runbooks, rollback and incident response |
| Security - apply security at all layers | Segmented VPC and SGs already specified | Implement SG/NACL isolation; **fix NAT public NACL HTTPS ingress**; add explicit verification | Public NACL 443, DB private route table, bucket encryption | Private-AZ live HTTPS egress, HTTPS/TLS, PCI, production IAM/WAF |
| Cost Optimization - control cost and monitor usage | OpEx and elastic scaling proposed | Use lab-sized dummy EC2, separate production baseline, choose basic-monitoring alarm periods and teardown | CloudFormation sizing, alarm and budget checks | Full TCO incl. Oracle/Windows licenses, production load |
| Business extension (outside six pillars) | CFO requested demand forecasting | New S3 ObjectCreated -> validated daily-sales Lambda -> per-input S3 JSON output | Upload a unique CSV; verify matching result and forecast | Accuracy, model selection, procurement workflow and data quality |

The additional rubric category is **subject to lecturer interpretation**; do not assume CloudFormation automatically qualifies as a separately graded "additional component" without the original detailed rubric.

## Learner Lab implementation boundary

The Learner Lab account does not expose `ap-southeast-6`, so the deployable prototype uses `us-east-1`. This is a lab constraint, not a production recommendation. The production recommendation remains the New Zealand Region where available, with CloudFront for global delivery.

The lab implementation also replaces production RDS Oracle and Windows/.NET instances with low-cost dummy EC2 services. This follows the assignment allowance for dummy app and database servers while still proving the network, ALB, Auto Scaling, monitoring, S3, Lambda, and tiering mechanics.

## Pillar 1 — Reliability

### Risk found

The original design described resilient AWS services, but Assignment 2 requires evidence that the architecture can actually be implemented and demonstrated. Reliability therefore needed to move from diagram-level claims to observable health and failover behaviour.

### Design update

The deployed prototype includes:

- Two Availability Zones.
- Public, application, and database subnets in each AZ.
- Public and internal Application Load Balancers.
- Frontend and backend Auto Scaling Groups.
- Health checks on both target groups.
- Auto Scaling target tracking policies.
- Two NAT Gateways so each application subnet has same-AZ outbound connectivity.

### Evidence to show

In AWS Console, show:

- CloudFormation stack status: `UPDATE_COMPLETE`.
- Frontend target group: 2 healthy targets.
- Backend target group: 2 healthy targets.
- Frontend ASG and backend ASG: desired capacity 2, max capacity 4.
- Browser path: `/` loads the frontend, `/api/` reaches the backend, and `/api/db/` reaches the private DB tier.

### Remaining production validation

The prototype proves tier routing and health checks. Production still needs real workload testing, Oracle migration validation, RTO/RPO targets, restore testing, and a formal disaster recovery strategy.

## Pillar 2 — Operational Excellence

### Risk found

The IT Manager has a small team and is already spending too much time patching, troubleshooting, and keeping the website running. A manually built cloud environment would not solve that problem.

### Design update

The implementation uses Infrastructure as Code:

- `template.yaml` defines the VPC, subnets, routes, NAT Gateways, NACLs, Security Groups, ALBs, Auto Scaling Groups, S3 bucket, Lambda function, CloudWatch alarm, and SNS topic.
- `deploy.sh` validates and deploys the CloudFormation stack.
- `verify.sh` asserts the live stack status, healthy cross-AZ app capacity, NACL/NAT configuration, HTTP response content, a unique fresh forecast output, and CloudWatch/SNS configuration.
- `destroy.sh` empties the S3 bucket and deletes the stack to control lab cost.

### Evidence to show

In AWS Console and terminal, show:

- CloudFormation stack resources.
- A repeatable deploy command.
- A repeatable verification command.
- The live ALB URL and forecasting output.

### Improvement discovered during testing

The first version used `dnf install httpd` during EC2 boot. The private instances failed target health checks because package installation was a runtime dependency. The prototype was improved to use Python standard library HTTP servers already available on the AMI. This reduced boot fragility and made the demonstration more reliable in private subnets.

## Pillar 3 — Security

### Risk found

The CISO is concerned about DDoS, PCI responsibilities, and data extraction. The implementation must not expose app or database instances directly to the Internet.

### Design update

The deployed prototype includes:

- Only the public ALB accepts public HTTP traffic.
- Frontend instances accept traffic only from the public ALB Security Group.
- The internal ALB accepts traffic only from the frontend Security Group.
- Backend instances accept traffic only from the internal ALB Security Group.
- The dummy database instance accepts traffic only from the backend Security Group.
- Database subnets use a local-only route table and do not have a default Internet route.
- The S3 bucket blocks public access and enables server-side encryption.
- The lab uses the pre-created `LabRole` and `LabInstanceProfile`, matching Learner Lab restrictions.

### Production boundary

The prototype supports secure architecture principles, but it does not prove PCI compliance by itself. A production implementation still needs payment-flow design, tokenisation, evidence collection, logging retention, vulnerability management, formal policy controls, and PCI assessment.

## Pillar 4 — Cost Optimization

### Risk found

A fully production-like deployment can burn Learner Lab budget quickly, especially with NAT Gateways, ALBs, RDS Oracle, and always-running EC2 capacity.

### Design update

The prototype balances rubric coverage and lab budget:

- Uses dummy EC2 for app and DB tiers where the assignment permits it.
- Uses small EC2 instance types.
- Avoids RDS Oracle in the lab prototype.
- Avoids deploying Shield Advanced or full WAF in the lab.
- Uses `destroy.sh` for cleanup after validation and recording.
- Keeps the production recommendation separate from the lab implementation.

### Trade-off

Two NAT Gateways and two ALBs cost more than a single-AZ toy environment. The trade-off is justified for the assignment because it demonstrates multi-AZ routing, private subnets, ELB, Auto Scaling, and resilience more clearly.

## Final assessment

The prototype is strong enough for Assignment 2 because it implements the core AWS resources, adds two additional components with business value, and provides live Console evidence for the pitch.

It is not production-ready yet. The biggest remaining unknowns are Oracle migration compatibility, real demand sizing, payment/PCI scope, restore testing, and exact operational runbooks.
