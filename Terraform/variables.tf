variable "aws_region" {
  description = "AWS region to provision resources"
  type = string
}
# Project name
variable "project_name" {
  description = "The name of the project"
  type        = string
}

# Environment (dev/prod)
variable "environment" {
  description = "The environment (dev/prod)"
  type        = string
}

# VPC CIDR block
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Public subnet CIDR
variable "public_subnet_cidr_1" {
  description = "CIDR block for the first public subnet"
  type        = string
}

variable "public_subnet_cidr_2" {
  description = "CIDR block for the second public subnet"
  type        = string
}




variable "db_subnet_cidr_1" {
  description = "CIDR block for first private DB subnet"
  type        = string
}

variable "db_subnet_cidr_2" {
  description = "CIDR block for second private DB subnet"
  type        = string
}

variable "private_subnet_cidr_1" {
  description = "CIDR block for first private subnet"
  type = string
}

variable "private_subnet_cidr_2" {
  description = "CIDR block for second private subnet"
  type = string
}

variable "db_name" {
  description = "The database name"
  type        = string
}

variable "db_username" {
  description = "The database master username"
  type        = string
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}



# EC2
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

# Web Server
variable "web_instance_type" {
  description = "Instance type for web server"
  type        = string
  default     = "t3.small"
}

variable "web_desired_capacity" {
  description = "Desired capacity for web server ASG"
  type        = number
  default     = 1
}

variable "web_min_size" {
  description = "Minimum size for web server ASG"
  type        = number
  default     = 1
}

variable "web_max_size" {
  description = "Maximum size for web server ASG"
  type        = number
  default     = 2
}

# App Server
variable "app_instance_type" {
  description = "Instance type for app server"
  type        = string
  default     = "t3.small"
}

variable "app_desired_capacity" {
  description = "Desired capacity for app server ASG"
  type        = number
  default     = 1
}

variable "app_min_size" {
  description = "Minimum size for app server ASG"
  type        = number
  default     = 1
}

variable "app_max_size" {
  description = "Maximum size for app server ASG"
  type        = number
  default     = 2
}

# Auto Scaling
variable "enable_autoscaling" {
  description = "Enable CPU based auto scaling"
  type        = bool
  default     = false
}


variable "github_org" {
  description = "GitHub organisation or username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "terraform_state_bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
}


variable "enable_https" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = ""
}