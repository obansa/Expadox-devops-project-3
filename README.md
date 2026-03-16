# CloudOpsHub Infrastructure

Automated Docker-Based Infrastructure Platform on AWS using Terraform.

## Overview

This repository contains the Terraform infrastructure code for CloudOpsHub — a multi-environment AWS platform supporting Dev, Staging and Production environments.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) v1.10+
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) v2
- Git
- AWS account with appropriate permissions

## Getting Started

### 1. Clone and checkout the infrastructure branch

```bash
git fetch origin
git checkout hajarat/terraform-infra
cd Terraform
```

### 2. Configure AWS credentials

```bash
aws configure
```

### 3. Create your S3 backend bucket

Each team member must create a **unique** S3 bucket for their Terraform state:

```bash
aws s3 mb s3://your-unique-bucket-name --region us-east-1
```

Update `conf/backend_dev` with your bucket name:

```hcl
bucket       = "your-unique-bucket-name"
key          = "cloudopshub/dev/terraform.tfstate"
region       = "us-east-1"
use_lockfile = true
```

### 4. Create your dev.tfvars file

Create `dev.tfvars` in the `Terraform/` folder using the template provided by the infra team.

> ⚠️ **Never commit `*.tfvars` files to GitHub.**

## Usage

### Initialise Terraform

```bash
terraform init -backend-config="conf/backend_dev"
```

### Validate configuration

```bash
terraform validate
```

### Preview infrastructure

```bash
terraform plan -var-file="dev.tfvars"
```

### Apply infrastructure

```bash
terraform apply -var-file="dev.tfvars"
```

Type `yes` when prompted.

### Destroy infrastructure

```bash
terraform destroy -var-file="dev.tfvars"
```

> ⚠️ **Always destroy resources after testing to avoid unnecessary AWS charges.**

## Modules

| Module | Description |
|--------|-------------|
| `modules/vpc` | VPC, public/private/DB subnets, NAT Gateway, IGW, route tables, security groups |
| `modules/ec2` | Launch templates, Auto Scaling Groups, SNS notifications |
| `modules/alb` | Application Load Balancer, target group, HTTP/HTTPS listeners |
| `modules/rds` | PostgreSQL RDS instance, DB subnet group, SSM parameter storage |
| `modules/iam` | EC2, ArgoCD, GitHub Actions OIDC and RDS monitoring roles |
| `modules/ecr` | Container registries for frontend and backend with lifecycle policies |
| `modules/s3` | S3 buckets for static assets, backups and logs |

## Environment Structure

| Resource | Dev | Staging | Prod |
|----------|-----|---------|------|
| EC2 Type | t3.small | t3.medium | t3.large |
| RDS Size | db.t3.micro | db.t3.small | db.m5.large |
| Multi-AZ | No | No | Yes |
| Auto Scale | No | Partial | Yes |

## Important Notes

- Each team member must use a **unique S3 bucket** for their backend state
- Get your AMI ID from AWS Console for your specific region
- RDS takes 5-10 minutes to create and destroy
- Use **SSM Session Manager** instead of SSH to connect to EC2 instances — no key pairs or open ports needed
- Production values are managed via GitHub Secrets — no `prod.tfvars` file

## Project Structure

```
Terraform/
├── main.tf                 # Root module - calls all modules
├── variables.tf            # Root variables
├── outputs.tf              # Root outputs
├── provider.tf             # AWS provider configuration
├── backend.tf              # Backend type declaration
├── conf/
│   ├── backend_dev         # Dev backend config
│   ├── backend_staging     # Staging backend config
│   └── backend_prod        # Prod backend config
└── modules/
    ├── vpc/
    ├── ec2/
    ├── alb/
    ├── rds/
    ├── iam/
    ├── ecr/
    └── s3/