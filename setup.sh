#!/bin/bash

aws eks --region us-west-2 update-kubeconfig --name xonotic-usw2-dev-eks --alias xonotic-usw2-dev-eks-cluster


kubectl get nodes
kubectl get svc