# INFOSYS 735 Assignment 2 — AnyGroupLLC

This folder contains the Learner Lab implementation of the Assignment 1 architecture.

## Prototype scope
- VPC `10.0.0.0/16`, two AZs, six /24 subnets
- Public and private route tables, two NAT Gateways
- Security Groups and custom NACLs
- Public ALB -> Frontend Auto Scaling Group
- Internal ALB -> Backend Auto Scaling Group
- Private dummy DB-tier EC2, as explicitly permitted by the assignment
- Private encrypted S3 bucket
- CloudWatch alarm -> SNS topic
- CloudFormation Infrastructure as Code
- Lambda + S3 forecasting feature for the CFO use case

## Relationship to Assignment 1
The production design remains Route 53 -> CloudFront/WAF/Shield -> public ALB -> Apache/Linux frontend ASG -> internal ALB -> .NET Core/Windows backend ASG -> RDS for Oracle Multi-AZ, with private S3 catalogue storage. The Learner Lab prototype validates the network/tier/scaling mechanics while using Amazon Linux dummy backend/database components to control cost and stay within lab restrictions.

## Region note
Assignment 1 proposed `ap-southeast-6` (New Zealand). The Learner Lab account does not have that opt-in Region enabled, so the deployable prototype uses `us-east-1`. This is an implementation-environment constraint, not a change to the production recommendation.

## Cost note
The stack creates two NAT Gateways, two ALBs, four Auto Scaling EC2 instances, and one dummy DB EC2. Deploy for validation/demo and delete when not needed.
