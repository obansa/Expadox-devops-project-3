variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment (dev/prod)"
  type        = string
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
  default     = "15"
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

variable "db_subnet_group_name" {
  description = "DB subnet group name from VPC module"
  type        = string
}

variable "db_sg_id" {
  description = "DB security group ID from VPC module"
  type        = string
}