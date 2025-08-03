#!/bin/bash

# EKS Cluster Cleanup Script

set -e

CLUSTER_NAME="my-eks-cluster"
REGION="us-west-2"

echo "Deleting EKS cluster: $CLUSTER_NAME"

# Delete the cluster (this will also delete node groups and add-ons)
eksctl delete cluster --name $CLUSTER_NAME --region $REGION

echo "EKS cluster $CLUSTER_NAME deleted successfully!"