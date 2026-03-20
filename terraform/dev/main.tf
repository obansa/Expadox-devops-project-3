terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = "us-east-1" }

module "ec2" {
  source   = "../modules/ec2"
  env      = "dev"
  key_name = var.key_name
}

resource "aws_s3_bucket" "static" {
  bucket = "cloudopshub-groupf-dev-static"
  tags   = { Project = "CloudOpsHub", Environment = "dev", Team = "GroupF" }
}

resource "aws_s3_bucket_versioning" "static" {
  bucket = aws_s3_bucket.static.id
  versioning_configuration { status = "Suspended" }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "cloudopshub-frontend"
  image_tag_mutability = "MUTABLE"
  tags                 = { Project = "CloudOpsHub", Team = "GroupF" }
}

resource "aws_ecr_repository" "backend" {
  name = "cloudopshub-backend"
  tags = { Project = "CloudOpsHub", Team = "GroupF" }
}

resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.frontend.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images only"
      selection    = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 5 }
      action       = { type = "expire" }
    }]
  })
}

resource "aws_db_instance" "main" {
  identifier          = "cloudopshub-dev-db"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp2"
  db_name             = "cloudopshub"
  username            = "admin"
  password            = var.db_password
  skip_final_snapshot = true
  publicly_accessible = false
  multi_az            = false
  deletion_protection = false
  tags                = { Project = "CloudOpsHub", Environment = "dev", Team = "GroupF" }
}

variable "key_name"    {}
variable "db_password" { sensitive = true }

output "ec2_ip"       { value = module.ec2.public_ip }
output "rds_endpoint" { value = aws_db_instance.main.endpoint }
