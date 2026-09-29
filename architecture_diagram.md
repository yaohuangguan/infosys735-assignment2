# Architecture Diagram

This diagram is the Assignment 2 deployed prototype. It remains traceable to the Assignment 1 production design but uses Learner Lab-friendly dummy services for the application and database tiers.

```mermaid
flowchart LR
  user[Internet users]
  alb[Public ALB\nanygroup-public-alb]

  subgraph vpc[VPC 10.0.0.0/16]
    subgraph aza[AZ A]
      pubA[Public subnet\n10.0.0.0/24\nNAT-A]
      appA[App subnet\n10.0.10.0/24\nFrontend + Backend EC2]
      dbA[DB subnet\n10.0.20.0/24\nDummy Oracle EC2]
    end

    subgraph azb[AZ B]
      pubB[Public subnet\n10.0.1.0/24\nNAT-B]
      appB[App subnet\n10.0.11.0/24\nFrontend + Backend EC2]
      dbB[DB subnet\n10.0.21.0/24\nReserved DB subnet]
    end

    front[Frontend Auto Scaling Group\nDesired 2 / Max 4]
    ialb[Internal ALB\nanygroup-internal-alb]
    back[Backend Auto Scaling Group\nDesired 2 / Max 4]
    db[Private DB tier\nDummy Oracle endpoint]
  end

  s3[S3 bucket\nprivate encrypted]
  lambda[Lambda\nanygroup-sales-forecast]
  cw[CloudWatch alarm]
  sns[SNS topic]

  user --> alb --> front --> ialb --> back --> db
  s3 -- ObjectCreated forecast-input/*.csv --> lambda
  lambda --> s3
  cw --> sns
```

## Deployed endpoint

`http://anygroup-public-alb-735612210.us-east-1.elb.amazonaws.com/`

Useful demo paths:

- `/` — frontend tier.
- `/api/` — frontend to backend through the internal ALB.
- `/api/db/` — backend to private database tier.

## Production baseline differences

The Assignment 1 production architecture still recommends:

- Route 53 and CloudFront for the customer-facing domain and global delivery.
- AWS WAF and Shield for edge filtering and DDoS resilience.
- Apache/Linux frontend Auto Scaling Group.
- .NET Core/Windows backend Auto Scaling Group.
- RDS for Oracle Multi-AZ.
- Private S3 catalogue-image storage through CloudFront Origin Access Control.

The Assignment 2 deployed prototype validates the architecture mechanics under Learner Lab constraints.
