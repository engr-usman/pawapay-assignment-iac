include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../../modules/eks/cluster//"
}

dependency "vpc" {
  config_path = "../../vpc"
}

inputs = {
  cluster_name        = "assignment-dev"
  cluster_version     = "1.32"
  vpc_id              = dependency.vpc.outputs.vpc_id
  private_subnet_ids  = dependency.vpc.outputs.private_subnets

  vpc_cidr           = dependency.vpc.outputs.vpc_cidr

  instance_type = "t3.medium"
  desired_size  = 1
  min_size      = 1
  max_size      = 5
  disk_size     = 50

  ssh_key_name = "ec2-key-nvirginia"

  tags = include.root.locals.common_tags
}