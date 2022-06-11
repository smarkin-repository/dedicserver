#!/bin/bash
set -x

aws eks --region us-west-2 update-kubeconfig --name xonotic-usw2-dev-eks --alias xonotic-usw2-dev-eks-cluster


kubectl get nodes
kubectl get svc

# print all AWS resources with tag "xonotic-usw2-dev-eks" 
aws resourcegroupstaggingapi get-resources --tag-filters Key=Stack,Values=xonotic --query "ResourceTagMappingList[].ResourceARN" --output json

helm repo add agones https://agones.dev/chart/stable
helm repo update