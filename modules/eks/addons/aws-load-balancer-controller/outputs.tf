output "service_account_name" {
  value = kubernetes_service_account.load_balancer_controller_sa.metadata[0].name
}

output "iam_role_arn" {
  value = aws_iam_role.load_balancer_controller_role.arn
}