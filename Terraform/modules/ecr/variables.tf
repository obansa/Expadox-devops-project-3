variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment (dev/prod)"
  type        = string
}

variable "repo_name" {
  description = "ECR repository name suffix (e.g. frontend, backend)"
  type        = string
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "lifecycle_days" {
  description = "Number of days before expiring untagged images"
  type        = number
  default     = 7
}