# Pitch Script and Demo Flow

Target length: approximately 15 minutes (11 slides; keep the sizing-feedback slide brief).

The presentation should be a stakeholder pitch, not a lab walkthrough. Use the AWS Console as evidence for business claims.

## Slide 1 — Opening

**Message:** We took the Assignment 1 architecture and turned it into a working AWS prototype.

Suggested script:

> Today we will show how the AnyGroupLLC cloud architecture moved from a proposal into a deployed AWS prototype. The goal is not only to list AWS services, but to show that the design supports availability, operations, security, cost control, and a business-facing forecasting feature.

## Slide 2 — Business challenges and expected outcomes

**Message:** This is a stakeholder recommendation, not a walkthrough of the marking rubric.

Mention:

- CEO/CTO: resilient e-commerce during promotions and growth.
- CISO: segmented access and demonstrable controls, while keeping PCI claims appropriately scoped.
- IT Manager: repeatable deployments, health checks and fewer manual operations.
- CFO: understandable spending trade-offs and an extensible sales forecasting workflow.

Use the final architecture and real AWS Console evidence to support these outcomes; move marking percentages to team preparation notes / appendix.

## Slide 3 — Production baseline

**Message:** We did not redesign from scratch. We carried forward the Assignment 1 architecture.

Mention:

- CloudFront, WAF, and Shield remain production edge controls.
- Public ALB, frontend ASG, internal ALB, backend ASG, and Oracle Multi-AZ remain the production traffic path.
- Private S3 remains the product-image storage pattern.

## Slide 4 — Migration sizing and production validation

**Message:** Turn the proposed AWS architecture into a credible initial migration plan without presenting untested numbers as final sizing.

**Provisional production sizing (not Learner Lab resources):**

- Frontend Apache/Linux: **EC2 `t3.medium`**, 2 vCPU / 4 GiB, two instances.
- Backend .NET/Windows: **EC2 `m6i.xlarge`**, 4 vCPU / 16 GiB, four instances across two AZs.
- Oracle database: **RDS `db.m6i.2xlarge`**, 8 vCPU / 32 GiB plus an initial ~2-TB storage target, Multi-AZ.
- Lab uses **`t3.micro` dummy applications and one dummy DB EC2**, not these production classes.

**Validation gates:** Confirm New Zealand Region availability, Oracle licensing/edition, CPU-vCPU differences, peak capacity, Windows overhead, IOPS, backup/restore and RTO/RPO. Apply right-sizing only after real measurements.

Suggested script:

> We have selected a preliminary migration baseline that is closer to AnyGroupLLC's existing compute and memory footprint. It gives us a starting point for cost estimates and realistic load testing, rather than assuming we can shrink capacity safely from day one. The Learner Lab uses much smaller simulated servers solely to verify the architecture.

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

1. Open the S3 bucket from the **current CloudFormation `ForecastBucket` output**.
2. Upload or show a new unique `forecast-input/*.csv` object.
3. Show the matching `forecast-output/runs/<input-basename>.csv.json` plus `forecast-output/latest.json`. Confirm that `source_key` matches the new input.
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

## Slide 10 — AWS Console demonstration order (no application browser page)

Recommended Console-only order:

1. CloudFormation stack info, resources and outputs.
2. Public and internal ALB details, **Listeners and rules** (forward to frontend/backend target groups).
3. Both target groups showing healthy instances.
4. Frontend and backend Auto Scaling Groups, cross-AZ instance placement and CPU target tracking.
5. Private dummy DB EC2 subnet and Security Group inbound TCP 8080 from backend.
6. S3 forecast input, Lambda trigger, matching S3 JSON output, CloudWatch alarm and SNS topic.

No raw ALB URL or `/api/` browser-tab demonstration is part of the recorded presentation. `verify.sh` provides the **separate** HTTP path verification for `/`, `/api/`, and `/api/db/`. Healthy targets and listener rules alone do not prove full end-to-end request behavior.


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
