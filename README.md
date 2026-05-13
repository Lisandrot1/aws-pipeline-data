# data-pipeline-aws

AWS Data Pipeline infrastructure using Terraform.

## Infrastructure Structure

```
pipeline-aws/
├── terraform/
│   ├── environments/
│   │   └── prod/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── backend.tf
│   ├── modules/
│   │   ├── s3-bucket/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── glue/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── lambda/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── step-function/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── athena/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── eventbridge/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   ├── data-lake/
│   │   ├── bronze.tf
│   │   ├── silver.tf
│   │   └── gold.tf
│   ├── pipelines/
│   │   ├── ingestion.tf
│   │   ├── transformation.tf
│   │   └── orchestration.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── versions.tf
│   └── outputs.tf
```

## AWS Services

| Module | Services |
|--------|----------|
| **s3-bucket** | S3 (Bronze/Silver/Gold buckets) |
| **glue** | Glue Crawlers, Jobs, Databases |
| **lambda** | Lambda Functions |
| **step-function** | Step Functions (State Machines) |
| **athena** | Athena WorkGroups, Named Queries |
| **eventbridge** | EventBridge Rules, Targets |

## Layers

- **data-lake/**: Bronze (raw), Silver (cleaned), Gold (aggregated) storage
- **pipelines/**: ETL pipeline definitions (ingestion, transformation, orchestration)
- **environments/**: Production environment configuration