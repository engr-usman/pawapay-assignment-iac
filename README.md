# 🚀 PawaPay Assignment – Infrastructure as Code (IaC)

Infrastructure deployment for AWS using Terraform and Terragrunt, implementing modular, reusable, and scalable infrastructure patterns.

---

## 📦 Project Overview

This repository contains the IaC implementation for deploying foundational AWS infrastructure components required for the PawaPay assignment. The project follows:

- **Terraform modules** for reusable infrastructure blocks
- **Terragrunt** for environment orchestration, state management, DRY structure, and dependency handling
- **Git-based workflow** for environment isolation and long-term maintainability

The primary goal of this stage is to provision a fully functional Amazon EKS cluster, including supporting resources such as VPC, subnets, IAM roles, and workload identities.

---

## 🏗️ Infrastructure Components Delivered

### ✅ 1. AWS VPC Module

A fully isolated, scalable networking layer including:

- Public & private subnets
- Internet & NAT gateways
- Route tables and associations
- VPC CIDR exposure for dependent modules

This VPC acts as the base networking layer for the EKS cluster.

---

### ✅ 2. Amazon EKS Cluster Module

A production-ready Kubernetes control plane with:

- Managed node groups
- IAM OpenID Connect (OIDC) integration
- Cluster endpoint and certificate outputs
- Terraform-driven dependency binding with Terragrunt

This ensures Kubernetes workloads run securely with least-privilege IAM roles.

---

### ✅ 3. AWS Load Balancer Controller (IRSA Setup Only)

As part of the assignment, IAM resources required for installing the AWS Load Balancer Controller were provisioned:

**Created via Terraform + Terragrunt:**
- IAM Policy for the controller
- IAM Role using IRSA (`sts:AssumeRoleWithWebIdentity`)
- Namespace-scoped Service Account annotated with the controller role

> **Note:** The Helm installation of the controller addon is intentionally not automated. The IAM prerequisites are created successfully and can be used to install the addon manually when needed.

---

### ⚠️ 4. Addons – Improvement Plan

Due to time complexity and Terragrunt behavior, the following Kubernetes addons were not fully automated in this iteration:

- Cluster Autoscaler
- Metrics Server
- EBS CSI Driver
- External Secrets Operator
- Node Termination Handler

**Current Status:**
- ✅ Policies, roles, and service accounts for Load Balancer Controller are created
- ❌ Full addon installation via Terraform `helm_release` is pending
- ❌ EBS CSI driver installation encountered IRSA credential-related issues

**Planned Improvement:**  
A future enhancement will automate all addons using Helm and Terraform, ensuring dependency ordering and kubernetes provider authentication are handled consistently across environments.

---

## 📁 Repository Structure

```
assignment-infra/
│
├── modules/
│   ├── vpc/
│   ├── eks/
│   │   ├── cluster/
│   │   └── addons/
│   │       └── aws-load-balancer-controller/
|   ├── ecr
|   ├── rds
│
├── live/
│   ├── dev/
│   │   ├── vpc/
│   │   ├── eks/
│   │   │   ├── cluster/
│   │   │   └── addons/
│   │   │       └── aws-load-balancer-controller/
|   |   ├── ecr/
|   |   ├── rds/
│   │   └── terragrunt.hcl
│
└── README.md
```

This layout follows Terragrunt best practices:
- `modules/` → Reusable building blocks
- `live/` → Per-environment deployments
- `dependency` blocks ensure correct apply ordering

---

## 🔧 Tools & Technologies Used

- **Terraform** (v1.x)
- **Terragrunt** (DRY pattern, hierarchical configuration)
- **AWS** EKS, IAM, VPC, OIDC
- **Kubernetes** (IRSA integration)
- **GitHub** (SSH-based Git workflow)

---

## ▶️ How to Deploy

### Initialize Terragrunt
```bash
terragrunt init
```

### Apply VPC
```bash
cd live/dev/vpc
terragrunt apply
```

### Apply EKS Cluster
```bash
cd ../eks/cluster
terragrunt apply
```

### Apply Load Balancer Controller (IAM prerequisites only)
```bash
cd ../addons/aws-load-balancer-controller
terragrunt apply
```

---

## 📌 Next Steps (Future Enhancements)

To complete the infrastructure automation:

### 🎯 Automate EKS Addons
- Cluster Autoscaler
- Metrics Server
- EBS CSI Driver
- External Secrets Operator
- Node Termination Handler

### 🎯 Resolve IRSA issues for EBS CSI Driver
IRSA trust relationships must match the cluster OIDC issuer exactly.

### 🎯 Add production environment (`live/prod`)
To support multi-environment deployments.

### 🎯 Introduce CI/CD for IaC
Using GitHub Actions for plan/apply workflows.

---

## 📝 Conclusion

This repository establishes a strong, modular, and scalable foundation for AWS EKS infrastructure using Terraform and Terragrunt. The IRSA model and IAM prerequisites for the Load Balancer Controller are successfully implemented. Addon automation will be addressed in the next iteration to further strengthen the Kubernetes ecosystem setup.

---

## 👤 Author

[Syed Usman Ahmad | DevOps Expert]