output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.address
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Database username"
  value       = aws_db_instance.main.username
}

output "ssm_db_password_path" {
  description = "SSM path for DB password"
  value       = aws_ssm_parameter.db_password.name
}

output "ssm_db_host_path" {
  description = "SSM path for DB host"
  value       = aws_ssm_parameter.db_host.name
}