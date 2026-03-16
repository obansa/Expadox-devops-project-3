locals {
  name_prefix = "${var.project_name}-${var.environment}"

  base_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ============================================
# S3 BUCKET
# ============================================

resource "aws_s3_bucket" "this" {
  bucket = "${local.name_prefix}-${var.bucket_name}"
  tags   = merge(local.base_tags, { Name = "${local.name_prefix}-${var.bucket_name}" })
}

# ============================================
# VERSIONING
# ============================================

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# ============================================
# ENCRYPTION
# ============================================

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ============================================
# BLOCK PUBLIC ACCESS
# ============================================

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}