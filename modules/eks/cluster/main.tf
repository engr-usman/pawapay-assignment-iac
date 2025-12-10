terraform {
  backend "s3" {}
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  cluster_name = var.cluster_name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnet_ids

  enable_irsa = true

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  #############################
  # MANAGED NODE GROUPS HERE
  #############################

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2_x86_64"
      desired_size   = var.desired_size
      max_size       = var.max_size
      min_size       = var.min_size
      instance_types = [var.instance_type]
      key_name       = var.ssh_key_name

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.disk_size
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
      }
    }
  }

  tags = var.tags
}

#############################
# EKS Cluster Security Group
#############################

resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.cluster_name}-cluster-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow worker nodes to talk to cluster API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "assignment-cluster-sg"
  })
}

resource "aws_security_group" "nodes" {
  name_prefix = "${var.cluster_name}-nodes-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow internal node-to-node"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow control plane kubelet"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "assignment-node-sg"
  })
}