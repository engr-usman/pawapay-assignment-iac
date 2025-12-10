include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../../../modules/eks/addons/aws-load-balancer-controller"
}

# ---- DEPENDENCY: EKS CLUSTER ----
dependency "eks" {
  config_path = "../../cluster"

  mock_outputs = {
    cluster_name                       = "dummy"
    cluster_oidc_issuer_url            = "https://dummy-issuer"
    vpc_id                             = "vpc-123456"
    region                             = "us-east-1"
    cluster_endpoint                   = "https://dummy"
    cluster_certificate_authority_data = ""
  }

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

# ---- DEPENDENCY: VPC MODULE ----
dependency "vpc" {
  config_path = "../../../vpc"
}

# ---- LOCALS ----
locals {
  region = include.root.locals.region
}

# ---- INPUTS FOR MODULE ----
inputs = {
  cluster_name            = dependency.eks.outputs.cluster_name
  cluster_oidc_issuer_url = dependency.eks.outputs.cluster_oidc_issuer_url
  vpc_id                  = dependency.vpc.outputs.vpc_id
  region                  = local.region

  service_account_name = "aws-load-balancer-controller"
  namespace            = "kube-system"

  tags = include.root.locals.common_tags
}