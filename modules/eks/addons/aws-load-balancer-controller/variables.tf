variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "EKS cluster OIDC issuer URL"
}

variable "service_account_name" {
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID used by ALB"
}

variable "tags" {
  type        = map(string)
  default     = {}
}