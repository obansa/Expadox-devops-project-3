locals {
  name_prefix = "${var.project_name}-${var.environment}"

  base_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ============================================
# ECR REPOSITORY
# ============================================

resource "aws_ecr_repository" "this" {
  name                 = "${local.name_prefix}-${var.repo_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(local.base_tags, { Name = "${local.name_prefix}-${var.repo_name}" })
}

# ============================================
# LIFECYCLE POLICY
# ============================================

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
  {
    rulePriority = 1
    description  = "Expire untagged images"
    selection = {
      tagStatus   = "untagged"
      countType   = "sinceImagePushed"
      countUnit   = "days"
      countNumber = var.lifecycle_days
    }
    action = { type = "expire" }
  },
  {
    rulePriority = 2  # ANY must have HIGHEST number
    description  = "Keep last 10 images"
    selection = {
      tagStatus   = "any"
      countType   = "imageCountMoreThan"
      countNumber = 10
    }
    action = { type = "expire" }
  }
]
  })
}