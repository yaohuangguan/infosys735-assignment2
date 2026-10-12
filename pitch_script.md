# Pitch Script and Demo Flow

Target length: approximately 15 minutes (11 slides; keep the sizing-feedback slide brief).

The presentation should be a stakeholder pitch, not a lab walkthrough. Use the AWS Console as evidence for business claims.

## Slide 1 — Opening

**Message:** We took the Assignment 1 architecture and turned it into a working AWS prototype.

Suggested script:

> Today we will show how the AnyGroupLLC cloud architecture moved from a proposal into a deployed AWS prototype. The goal is not only to list AWS services, but to show that the design supports availability, operations, security, cost control, and a business-facing forecasting feature.

## Slide 2 — Assignment 2 strategy

**Message:** The work is aligned to the marking structure.

Mention:

- Design improvement through Well-Architected review.
- Core AWS components deployed in Learner Lab.
- Additional components for business value.
- Live demo evidence for the 40-mark pitch.

## Slide 3 — Production baseline

**Message:** We did not redesign from scratch. We carried forward the Assignment 1 architecture.

Mention:

- CloudFront, WAF, and Shield remain production edge controls.
- Public ALB, frontend ASG, internal ALB, backend ASG, and Oracle Multi-AZ remain the production traffic path.
- Private S3 remains the product-image storage pattern.

## Slide 4 — Assignment 1 feedback: initial production sizing

**Message:** We acted on the instructor's specific feedback by identifying preliminary production instance classes while preserving the low-cost Learner Lab configuration.

**Production recommendations (not lab resources):**

- Frontend Apache/Linux: **EC2 `t3.medium`**, 2 vCPU / 4 GiB, starting with two instances across AZs.
- Backend .NET/Windows: **EC2 `m6i.large`**, 2 vCPU / 8 GiB, starting with two instances across AZs.
- Oracle database: **RDS `db.m6i.large`**, 2 vCPU / 8 GiB, initial Multi-AZ proposal.
- Learner Lab remains **`t3.micro` dummy services**, not the above production classes.

**Validation gates:** Check `ap-southeast-6` class/engine availability, Oracle edition/licensing, frontend T3 credit behavior, Windows memory needs, DB IOPS, load testing and DR targets. These are starting assumptions, not benchmarked final sizes.

Suggested script:

> Following Assignment 1 feedback, we now specify starting instance types for each production tier. We propose t3.medium for the Linux frontend, m6i.large for the Windows .NET backend and db.m6i.large for Oracle RDS Multi-AZ. These are provisional choices to validate against load, licensing, regional availability and recovery targets. The Learner Lab deliberately keeps its low-cost dummy servers unchanged.

## Slide 5 — Learner Lab constraints

**Message:** The prototype is a lab-constrained implementation, not a change to the production recommendation.

Mention:

- Production target remains New Zealand Region where available.
- Learner Lab deployment uses `us-east-1` because the lab account does not expose `ap-southeast-6`.
- Dummy EC2 is used for app and database tiers because the assignment allows dummy app and DB servers.

## Slide 6 — Deployed resource coverage

**Message:** The implementation covers the assignment's required services.

Console evidence:

1. Open CloudFormation.
2. Select stack `anygroupllc-a2`.
3. Show status `UPDATE_COMPLETE`.
4. Show Resources tab with VPC, subnets, route tables, NAT Gateways, ALBs, ASGs, EC2 instances, S3, Lambda, CloudWatch, and SNS.

Suggested script:

> The value of using CloudFormation is that this environment is repeatable. We can destroy and recreate it without manually clicking through dozens of services.

## Slide 7 — Forecasting feature

**Message:** The additional feature directly addresses the CFO's demand-forecasting concern.

Console evidence:

1. Open S3 bucket `anygroupllc-a2-332702858057-us-east-1`.
2. Show `forecast-input/sample-sales.csv`.
3. Show `forecast-output/latest.json`.
4. Open Lambda function `anygroup-sales-forecast`.
5. Show recent CloudWatch logs if needed.

Suggested script:

> This is intentionally a simple moving-average prototype. The purpose is to prove an extensible data flow: sales data lands in S3, an event triggers serverless processing, and the forecast output is written back to S3. In production, the model could become more sophisticated after data quality and business granularity are validated.

## Slide 8 — Reliability and Operational Excellence

**Message:** These two pillars are strongly evidenced by the live implementation.

Console evidence:

1. Open EC2 Target Groups.
2. Show `anygroup-front-tg` with 2 healthy targets.
3. Show `anygroup-back-tg` with 2 healthy targets.
4. Open Auto Scaling Groups.
5. Show frontend and backend ASGs with desired capacity 2 and max capacity 4.

Suggested script:

> Reliability is demonstrated through health-checked load balancing across two Availability Zones. Operational excellence is demonstrated through Infrastructure as Code and repeatable verification scripts.

## Slide 9 — Security and Cost Optimization

**Message:** The prototype demonstrates key controls while acknowledging production compliance boundaries.

Console evidence:

1. Show Security Groups chain: public ALB, frontend, internal ALB, backend, DB.
2. Show database route table has no default route.
3. Show S3 bucket blocks public access.
4. Mention cost cleanup with `destroy.sh`.

Suggested script:

> We should describe this as supporting PCI-aligned architecture principles, not as proving PCI compliance. Compliance depends on payment-flow design, policies, evidence, and formal assessment.

## Slide 10 — Live demo order

Recommended Console order:

1. CloudFormation stack and outputs.
2. Public ALB URL.
3. Target groups.
4. Auto Scaling Groups.
5. S3 and Lambda forecast output.
6. CloudWatch alarm and SNS topic.

Public URL:

`http://anygroup-public-alb-735612210.us-east-1.elb.amazonaws.com/`

HTTP paths:

- `/` shows the frontend.
- `/api/` proves frontend to backend.
- `/api/db/` proves backend to private database tier.

## Slide 11 — Recommendation

**Message:** The architecture direction is strong, but production still requires validation.

Mention proven items:

- Multi-AZ routing and tier isolation.
- ALB and Auto Scaling health-based replacement.
- S3/Lambda forecasting extension.
- CloudWatch/SNS operational visibility.

Mention remaining validation:

- Oracle compatibility and licensing.
- PCI/payment design.
- Load testing and capacity sizing.
- RTO/RPO and restore testing.

Close:

> Our recommendation is to proceed with this AWS direction. The prototype shows that the architecture is implementable, operationally repeatable, and extensible toward business forecasting, while keeping the remaining production risks explicit.
