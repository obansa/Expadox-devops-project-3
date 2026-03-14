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


# Allowed IP for SSH access
variable "allowed_cidr" {
  description = "Your public IP address for SSH access (e.g., 203.0.113.5/32)"
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