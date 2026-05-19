# AGENTS.md

## Project
AWS Data Pipeline infrastructure (Terraform) provisioning S3 bronze/silver/gold buckets, Glue crawlers/catalog, and a Lambda function.

## Structure
- `terraform/` — root Terraform config. Run all `terraform` commands from here.
- `terraform/modules/` — reusable modules: `s3`, `glue`, `lambda`
- `src/lambda/` — Python Lambda source code
- `requirements.txt` — Python deps (only `boto3`)
- `venv/` — Python 3.12 virtual env

## Commands
```bash
# Terraform (from terraform/)
terraform init
terraform plan
terraform apply

# Lambda local test
python src/lambda/identity_data.py
```

## Key details
- **Region**: `us-east-1` (set in `terraform.tfvars`)
- **Lambda runtime**: Python 3.12, handler `identity_data.lambda_handler`
- **Lambda packaging**: Terraform `archive_file` data source zips `src/lambda/identity_data.py` → `src/lambda/identity_data.zip` automatically on plan/apply. Do not manually manage the zip.
- **S3 buckets**: bronze (`brz-logs-ecommerce`), silver (`slv-logs-ecommerce`), gold (`gld-logs-ecommerce`) — all with versioning, lifecycle rules, and public access blocked.
- **Glue**: Only the bronze crawler is active. Silver and gold Glue modules are commented out in `terraform/main.tf`.
- **IAM**: Roles and policies defined in `iam.tf` and `policy.tf`. Crawler role (`data-crawler-role`) and Lambda role (`rol_read_lambda_s3`).
- **tfvars**: `terraform.tfvars` is gitignored but present locally with all variable values.

## Conventions
- Variable descriptions are in Spanish; code/comments mix English and Spanish.
- No CI/CD, linting, or test framework configured.
