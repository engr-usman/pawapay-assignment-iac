include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../../modules/eks/addons/metrics-server//"
}

dependency "eks" {
  config_path = "../../cluster"
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
  namespace    = "kube-system"

  tags = include.root.locals.common_tags
}