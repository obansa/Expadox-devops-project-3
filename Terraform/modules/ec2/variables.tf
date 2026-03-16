variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment (dev/prod)"
  type        = string
}

variable "server_role" {
  description = "Role of the server: web, app, or db"
  type        = string
  default     = "web"

  validation {
    condition     = contains(["web", "app", "db"], var.server_role)
    error_message = "server_role must be one of: web, app, db"
  }
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 2
}

variable "target_group_arn" {
  description = "ALB target group ARN to attach ASG to"
  type        = string
  default     = ""
}



variable "enable_autoscaling" {
  description = "Enable CPU-based auto scaling policies"
  type        = bool
  default     = false
}

variable "enable_alb_attachment" {
  description = "Enable ALB target group attachment"
  type        = bool
  default     = false
}