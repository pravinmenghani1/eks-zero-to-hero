#!/bin/bash

# EKS Cluster Creation Script
# Creates EKS 1.33 cluster with Amazon Linux 2023 node groups and all add-ons

set -e

# Configuration
CLUSTER_NAME="my-eks-cluster"
REGION="us-west-2"
NODE_GROUP_NAME="worker-nodes"
INSTANCE_TYPE="t3.medium"
MIN_NODES=2
MAX_NODES=4
DESIRED_NODES=2

echo "Creating EKS cluster: $CLUSTER_NAME"

# Create EKS cluster
eksctl create cluster \
  --name $CLUSTER_NAME \
  --version 1.33 \
  --region $REGION \
  --nodegroup-name $NODE_GROUP_NAME \
  --node-type $INSTANCE_TYPE \
  --nodes $DESIRED_NODES \
  --nodes-min $MIN_NODES \
  --nodes-max $MAX_NODES \
  --node-ami-family AmazonLinux2023 \
  --managed \
  --with-oidc

echo "Waiting for cluster to be ready..."
aws eks wait cluster-active --name $CLUSTER_NAME --region $REGION

# Update kubeconfig
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo "Installing add-ons..."

# Install EKS Pod Identity add-on
aws eks create-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name eks-pod-identity-agent \
  --region $REGION

# Install Amazon EBS CSI driver
aws eks create-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name aws-ebs-csi-driver \
  --region $REGION

# Install Amazon CloudWatch Observability agent
aws eks create-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name amazon-cloudwatch-observability \
  --region $REGION

echo "Waiting for add-ons to be active..."
aws eks wait addon-active --cluster-name $CLUSTER_NAME --addon-name eks-pod-identity-agent --region $REGION
aws eks wait addon-active --cluster-name $CLUSTER_NAME --addon-name aws-ebs-csi-driver --region $REGION
aws eks wait addon-active --cluster-name $CLUSTER_NAME --addon-name amazon-cloudwatch-observability --region $REGION

# Check add-on status
echo "Checking add-on status:"
echo "VPC CNI: $(aws eks describe-addon --cluster-name $CLUSTER_NAME --addon-name vpc-cni --region $REGION --query 'addon.status' --output text)"
echo "kube-proxy: $(aws eks describe-addon --cluster-name $CLUSTER_NAME --addon-name kube-proxy --region $REGION --query 'addon.status' --output text)"
echo "CoreDNS: $(aws eks describe-addon --cluster-name $CLUSTER_NAME --addon-name coredns --region $REGION --query 'addon.status' --output text)"
echo "Metrics Server: $(aws eks describe-addon --cluster-name $CLUSTER_NAME --addon-name metrics-server --region $REGION --query 'addon.status' --output text)"
echo "EKS Pod Identity: $(aws eks describe-addon --cluster-name $CLUSTER_NAME --addon-name eks-pod-identity-agent --region $REGION --query 'addon.status' --output text)"
echo "EBS CSI Driver: $(aws eks describe-addon --cluster-name $CLUSTER_NAME --addon-name aws-ebs-csi-driver --region $REGION --query 'addon.status' --output text)"
echo "CloudWatch Observability: $(aws eks describe-addon --cluster-name $CLUSTER_NAME --addon-name amazon-cloudwatch-observability --region $REGION --query 'addon.status' --output text)"

echo "Verifying cluster and nodes:"
kubectl get nodes
kubectl get pods -A

echo "EKS cluster $CLUSTER_NAME created successfully with all add-ons!"
echo "Cluster endpoint: $(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.endpoint' --output text)"