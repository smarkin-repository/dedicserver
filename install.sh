#!/bin/bash

set -x
# install agones

helm install demo-1.0.0 --namespace agones-system --create-namespace agones/agones

# install simple-cluster

kubectl create namespace simple-game-server
kubectl create -f ./apps/simple-game-server/gameserver.yaml -n simple-game-server

instance_id=$(aws ec2 describe-instances --filters Name=tag:eks:cluster-name,Values=xonotic-usw2-dev-eks Name=tag:Name,Values=complete --query "Reservations[].Instances[].InstanceId" --output text)
instance_ip=$(aws ec2 describe-instances --filters Name=tag:eks:cluster-name,Values=xonotic-usw2-dev-eks Name=tag:Name,Values=complete --query "Reservations[].Instances[].PrivateIpAddress" --output text)

echo "id:ip ($instance_id: $instance_ip)"
# aws ssm start-session --target $instance_id --document-name AWS-StartSSMSession
# send command via aws SSM 
# aws ssm send-command \
#     --instance-ids $instance_id \
#     --document-name "AWS-RunShellScript" \
#     --parameters 'commands=["echo HelloWorld"]' \
#     --comment "echo HelloWorld"
