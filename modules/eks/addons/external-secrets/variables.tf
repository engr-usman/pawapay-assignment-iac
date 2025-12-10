variable "cluster_name" { type = string }
variable "cluster_oidc_issuer_url" { type = string }

variable "service_account_name" {
  type    = string
  default = "aws-secrets-manager"
}

variable "namespace" {
  type    = string
  default = "kube-system"
}

variable "region" {
  type        = string
  description = "AWS region for External Secrets Operator"
}

variable "tags" {
  type    = map(string)
  default = {}
}