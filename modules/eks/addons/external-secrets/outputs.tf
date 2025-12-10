output "service_account_name" {
  value = kubernetes_service_account.aws_secrets_manager_sa.metadata[0].name
}

output "iam_role_arn" {
  value = aws_iam_role.secrets_manager_role.arn
}