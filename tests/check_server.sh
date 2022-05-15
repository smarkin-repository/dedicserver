#!/bin/bash

echo "Try to check simple server ..."

region="eu-north-1"

INSTANCE_ID=$(aws autoscaling describe-auto-scaling-instances --region eu-north-1 | jq --raw-output ".AutoScalingInstances | .[0] | .InstanceId")

if [ $INSTANCE_ID == "null" ]; then
    echo "Error: No AutoScalingInstances."
    exit 1
fi

echo "Checking sending commands  via  ssm instance ${INSTANCE_ID}"

aws ssm send-command \
    --region eu-north-1 \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["echo HelloWorld"]' \
    --instance-ids "${INSTANCE_ID}" \
    --comment "echo HelloWorld"


echo "Checking simple server  via  ssm instance ${INSTANCE_ID}"

IP="172.30.0.0"
PORT="8080"

sh_command_id=$(aws ssm send-command \
    --region eu-north-1 \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=[
        "nc -w 4 172.30.0.0 8080", 
        "if [ $? != 0 ]; then echo \"Failed\"; exit 1; fi",
        ]' \
    --instance-ids "${INSTANCE_ID}" \
    --comment "echo send Hello to the server" \
    --output text \
    --query "Command.CommandId")

echo "Command id $sh_command_id"

sleep 5 

aws ssm list-commands --command-id $sh_command_id  --region eu-north-1

#nc -u ${IP} ${PORT}
#
#Hello World !
#ACK: Hello World !
#EXIT
