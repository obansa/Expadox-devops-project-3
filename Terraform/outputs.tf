# VPC
output "vpc_id" {
  value = module.vpc.vpc_id
}

# ALB
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}

# RDS
output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "ssm_db_password_path" {
  value = module.rds.ssm_db_password_path
}

# ECR
output "ecr_frontend_url" {
  value = module.ecr_frontend.repository_url
}

output "ecr_backend_url" {
  value = module.ecr_backend.repository_url
}

# IAM
output "ec2_instance_profile_name" {
  value = module.iam.ec2_instance_profile_name
}

output "github_actions_role_arn" {
  value = module.iam.github_actions_role_arn
}