include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../modules/vpc//"
}

inputs = {
  vpc_cidr = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]

  private_subnets = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
  ]

  azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = include.root.locals.common_tags
}