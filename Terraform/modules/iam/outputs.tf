output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "ec2_role_arn" {
  description = "EC2 IAM role ARN"
  value       = aws_iam_role.ec2_role.arn
}

output "argocd_instance_profile_name" {
  description = "ArgoCD instance profile name"
  value       = aws_iam_instance_profile.argocd_instance_profile.name
}

output "argocd_role_arn" {
  description = "ArgoCD IAM role ARN"
  value       = aws_iam_role.argocd_role.arn
}

output "github_actions_role_arn" {
  description = "GitHub Actions IAM role ARN"
  value       = aws_iam_role.github_actions_role.arn
}

output "rds_monitoring_role_arn" {
  description = "RDS monitoring IAM role ARN"
  value       = aws_iam_role.rds_monitoring_role.arn
}