# EKS Cluster Setup

This repository contains scripts to create and manage an EKS cluster with version 1.33 and Amazon Linux 2023 node groups.

## Prerequisites

- AWS CLI configured with appropriate permissions
- eksctl installed
- kubectl installed

## Usage

### Create EKS Cluster
```bash
./create-eks-cluster.sh
```

### Delete EKS Cluster
```bash
./cleanup-eks-cluster.sh
```

## Cluster Configuration

- **Kubernetes Version**: 1.33
- **Node AMI**: Amazon Linux 2023
- **Node Count**: 2 (min: 2, max: 4)
- **Instance Type**: t3.medium

## Installed Add-ons

- VPC CNI
- kube-proxy
- CoreDNS
- EKS Pod Identity Agent
- Amazon EBS CSI Driver
- Amazon CloudWatch Observability Agent
- Metrics Server

## Customization

Edit the configuration variables at the top of `create-eks-cluster.sh`:
- CLUSTER_NAME
- REGION
- INSTANCE_TYPE
- MIN_NODES/MAX_NODES/DESIRED_NODES