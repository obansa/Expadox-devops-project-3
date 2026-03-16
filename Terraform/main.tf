module "vpc" {
  source = "./modules/vpc"

  project_name          = var.project_name
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidr_1  = var.public_subnet_cidr_1
  public_subnet_cidr_2  = var.public_subnet_cidr_2
  private_subnet_cidr_1 = var.private_subnet_cidr_1
  private_subnet_cidr_2 = var.private_subnet_cidr_2
  db_subnet_cidr_1      = var.db_subnet_cidr_1
  db_subnet_cidr_2      = var.db_subnet_cidr_2
  alb_sg_id = module.alb.alb_sg_id
}


module "rds" {
  source = "./modules/rds"
  project_name = var.project_name
  environment = var.environment
  db_name = var.db_name
  db_username = var.db_username
  engine_version = var.engine_version
  instance_class = var.instance_class
  allocated_storage = var.allocated_storage
  multi_az = var.multi_az
  db_subnet_group_name = module.vpc.db_subnet_group_name
  db_sg_id = module.vpc.db_sg_id
}

# --------------------------------------
# Web Server (NGINX - public subnet)
# --------------------------------------
module "web_server" {
  source = "./modules/ec2"

  project_name       = var.project_name
  environment        = var.environment
  server_role        = "web"
  ami_id             = var.ami_id
  instance_type      = var.web_instance_type
  key_name           = var.key_name
  security_group_ids = [module.vpc.public_sg_id]
  subnet_ids         = module.vpc.public_subnet_ids
  desired_capacity   = var.web_desired_capacity
  min_size           = var.web_min_size
  max_size           = var.web_max_size
  target_group_arn   = module.alb.target_group_arn
  enable_alb_attachment = true
  
}

# --------------------------------------
# App Server (Docker - private subnet)
# --------------------------------------
module "app_server" {
  source = "./modules/ec2"
  project_name       = var.project_name
  environment        = var.environment
  server_role        = "app"
  ami_id             = var.ami_id
  instance_type      = var.app_instance_type
  key_name           = var.key_name
  security_group_ids = [module.vpc.private_sg_id]
  subnet_ids         = module.vpc.private_subnet_ids
  desired_capacity   = var.app_desired_capacity
  min_size           = var.app_min_size
  max_size           = var.app_max_size
  enable_alb_attachment = false
  
}


# --------------------------------------
# IAM Module
# --------------------------------------
module "iam" {
  source = "./modules/iam"

  project_name           = var.project_name
  environment            = var.environment
  aws_region             = var.aws_region
  github_org             = var.github_org
  github_repo            = var.github_repo
  terraform_state_bucket = var.terraform_state_bucket
}


#ecr module

module "ecr_frontend" {
  source       = "./modules/ecr"
  project_name = var.project_name
  environment  = var.environment
  repo_name    = "frontend"
}

module "ecr_backend" {
  source       = "./modules/ecr"
  project_name = var.project_name
  environment  = var.environment
  repo_name    = "backend"
}




module "s3_static" {
  source       = "./modules/s3"
  project_name = var.project_name
  environment  = var.environment
  bucket_name  = "static"
}

module "s3_backups" {
  source       = "./modules/s3"
  project_name = var.project_name
  environment  = var.environment
  bucket_name  = "backups"
}

module "s3_logs" {
  source            = "./modules/s3"
  project_name      = var.project_name
  environment       = var.environment
  bucket_name       = "logs"
  enable_versioning = false
}


# --------------------------------------
# ALB Module
# --------------------------------------
module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_1_id = module.vpc.public_subnet_ids[0]
  public_subnet_2_id = module.vpc.public_subnet_ids[1]
  target_type        = "instance"
  enable_https       = var.enable_https
  certificate_arn    = var.certificate_arn
}