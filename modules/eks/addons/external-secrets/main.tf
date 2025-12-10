terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

locals {
  oidc_provider = replace(var.cluster_oidc_issuer_url, "https://", "")
}

###############################################
# IAM POLICY
###############################################

resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "EKSSecretsManagerPolicy"
  description = "IAM policy for AWS Secrets Manager integration with EKS"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:*"
        ]
      }
    ]
  })
}

###############################################
# IAM ROLE (IRSA)
###############################################

resource "aws_iam_role" "secrets_manager_role" {
  name = "EKSSecretsManagerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${local.oidc_provider}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}",
            "${local.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  role       = aws_iam_role.secrets_manager_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

###############################################
# SERVICE ACCOUNT (with IRSA annotation)
###############################################

resource "kubernetes_service_account" "aws_secrets_manager_sa" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.secrets_manager_role.arn
    }
  }
}

resource "kubernetes_secret" "aws_secrets_manager_token" {
  metadata {
    name      = "${var.service_account_name}-token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.aws_secrets_manager_sa.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

###############################################
# HELM RELEASE (External Secrets Operator)
###############################################

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = var.namespace

  depends_on = [kubernetes_service_account.aws_secrets_manager_sa]

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
  }

  set {
    name  = "aws.region"
    value = var.region
  }
}