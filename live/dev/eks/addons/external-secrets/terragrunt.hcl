include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../../modules/eks/addons/external-secrets//"
}

dependency "eks" {
  config_path = "../../cluster"
}

inputs = {
  cluster_name          = dependency.eks.outputs.cluster_name
  cluster_oidc_issuer_url = dependency.eks.outputs.cluster_oidc_issuer_url
  service_account_name  = "aws-secrets-manager"
  namespace             = "kube-system"
  region                = local.region

  tags = include.root.locals.common_tags
}