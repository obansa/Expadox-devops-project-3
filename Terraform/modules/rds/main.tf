locals {
  name_prefix = "${var.project_name}-${var.environment}"

  base_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# --------------------------------------
# Generate DB Master Password
# --------------------------------------
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# --------------------------------------
# Store DB credentials in SSM
# --------------------------------------
resource "aws_ssm_parameter" "db_name" {
  name      = "/${var.project_name}/${var.environment}/db/name"
  type      = "String"
  value     = var.db_name
  overwrite = true
  tags      = merge(local.base_tags, { Name = "${local.name_prefix}-ssm-db-name" })
}

resource "aws_ssm_parameter" "db_username" {
  name      = "/${var.project_name}/${var.environment}/db/username"
  type      = "String"
  value     = var.db_username
  overwrite = true
  tags      = merge(local.base_tags, { Name = "${local.name_prefix}-ssm-db-username" })
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.project_name}/${var.environment}/db/password"
  type        = "SecureString"
  value       = random_password.db_password.result
  overwrite   = true
  tags        = merge(local.base_tags, { Name = "${local.name_prefix}-ssm-db-password" })
}

resource "aws_ssm_parameter" "db_host" {
  name      = "/${var.project_name}/${var.environment}/db/host"
  type      = "String"
  value     = aws_db_instance.main.address
  overwrite = true
  tags      = merge(local.base_tags, { Name = "${local.name_prefix}-ssm-db-host" })

  depends_on = [aws_db_instance.main]
}

# --------------------------------------
# RDS MySQL Instance
# --------------------------------------
resource "aws_db_instance" "main" {
  identifier        = "${local.name_prefix}-rds"
  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_sg_id]

  multi_az            = var.multi_az
  publicly_accessible = false
  storage_encrypted   = true
  skip_final_snapshot = true

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  tags = merge(local.base_tags, { Name = "${local.name_prefix}-rds" })
}

