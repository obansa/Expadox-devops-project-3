variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment (dev/prod)"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name suffix (e.g. static, backups, logs)"
  type        = string
}

variable "enable_versioning" {
  description = "Enable bucket versioning"
  type        = bool
  default     = true
}