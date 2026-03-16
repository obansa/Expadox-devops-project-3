locals {
  name_prefix = "${var.project_name}-${var.environment}"

  base_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

data "aws_caller_identity" "current" {}

# ============================================
# SHARED POLICY DOCUMENT
# ============================================

data "aws_iam_policy_document" "ec2_policy" {

  # ECR - authorization token (must be *)
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # ECR - pull images (scoped to project)
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.project_name}-*"
    ]
  }

  # SSM - read parameters (scoped to project)
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/${var.environment}/*"
    ]
  }

  # CloudWatch - send logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  # S3 - read project buckets
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.project_name}-*",
      "arn:aws:s3:::${var.project_name}-*/*"
    ]
  }
}

# ============================================
# EC2 ROLE
# ============================================

resource "aws_iam_role" "ec2_role" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.base_tags, { Name = "${local.name_prefix}-ec2-role" })
}

resource "aws_iam_role_policy" "ec2_policy_attachment" {
  name   = "${local.name_prefix}-ec2-policy"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.ec2_policy.json
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${local.name_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
  tags = merge(local.base_tags, { Name = "${local.name_prefix}-ec2-instance-profile" })
}

# ============================================
# ARGOCD ROLE
# ============================================

resource "aws_iam_role" "argocd_role" {
  name = "${local.name_prefix}-argocd-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Role" = "argocd"
          }
        }
      }
    ]
  })

  tags = merge(local.base_tags, { Name = "${local.name_prefix}-argocd-role" })
}

resource "aws_iam_role_policy" "argocd_policy_attachment" {
  name   = "${local.name_prefix}-argocd-policy"
  role   = aws_iam_role.argocd_role.id
  policy = data.aws_iam_policy_document.ec2_policy.json
}

resource "aws_iam_instance_profile" "argocd_instance_profile" {
  name = "${local.name_prefix}-argocd-instance-profile"
  role = aws_iam_role.argocd_role.name
  tags = merge(local.base_tags, { Name = "${local.name_prefix}-argocd-instance-profile" })



  
}

# ============================================
# GITHUB ACTIONS ROLE (OIDC)
# ============================================

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = merge(local.base_tags, { Name = "${local.name_prefix}-github-oidc" })
}

resource "aws_iam_role" "github_actions_role" {
  name = "${local.name_prefix}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = merge(local.base_tags, { Name = "${local.name_prefix}-github-actions-role" })
}

data "aws_iam_policy_document" "github_actions_policy" {

  # ECR - push images
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.project_name}-*"
    ]
  }

  # S3 - Terraform state
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.terraform_state_bucket}",
      "arn:aws:s3:::${var.terraform_state_bucket}/*"
    ]
  }

  # EC2 - manage deployments
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:UpdateAutoScalingGroup"
    ]
    resources = ["*"]
  }

  # CloudWatch - send pipeline logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions_policy_attachment" {
  name   = "${local.name_prefix}-github-actions-policy"
  role   = aws_iam_role.github_actions_role.id
  policy = data.aws_iam_policy_document.github_actions_policy.json
}

# ============================================
# RDS MONITORING ROLE
# ============================================

resource "aws_iam_role" "rds_monitoring_role" {
  name = "${local.name_prefix}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.base_tags, { Name = "${local.name_prefix}-rds-monitoring-role" })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_attachment" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# SSM managed policy for EC2
resource "aws_iam_role_policy_attachment" "ec2_ssm_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# SSM managed policy for ArgoCD
resource "aws_iam_role_policy_attachment" "argocd_ssm_attachment" {
  role       = aws_iam_role.argocd_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}