terraform {
  backend "s3" {}
}

########################################
# Data sources for EKS cluster
########################################
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

##############################################
# IAM Policy for AWS Load Balancer Controller
##############################################

resource "aws_iam_policy" "load_balancer_controller_policy" {
  name        = "AWSLoadBalancerControllerPolicy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("${path.module}/iam-policy.json")
}

###############################################
# IAM Role for Load Balancer Controller (IRSA)
###############################################

locals {
  oidc_provider = replace(var.cluster_oidc_issuer_url, "https://", "")
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider}"
}

resource "aws_iam_role" "load_balancer_controller_role" {
  name = "AWSLoadBalancerControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = local.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${local.oidc_provider}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
            "${local.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lb_policy" {
  role       = aws_iam_role.load_balancer_controller_role.name
  policy_arn = aws_iam_policy.load_balancer_controller_policy.arn
}

##############################################
# ServiceAccount for Load Balancer Controller
##############################################

resource "kubernetes_service_account" "load_balancer_controller_sa" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.load_balancer_controller_role.arn
    }
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
}