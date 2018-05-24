#!/bin/sh
# manage_ami: - description
# Usage: manage_ami <region> <ami>
# Example: manage_ami us-east-1 ami-2f3a6954

if [ -z "$1" ]
  then
    echo "No <region> parameter supplied"
    echo "Usage: manage_ami <region> <ami>"
    echo "Example: manage_ami us-east-1 ami-2f3a6954"
    exit

fi

if [ -z "$2" ]
  then
    echo "No <ami> parameter supplied"
    echo "Usage: manage_ami "$1" <ami>"
    echo "Example: manage_ami "$1" ami-2f3a6954"
    exit

fi

region=$1
ami=$2

echo "Deploying AMI "$ami"..."
aws ec2 run-instances --image-id $ami --region $region > instance_details.txt
echo "Getting Instance ID..."
instanceId=`cat instance_details.txt |grep InstanceId |cut -d'"' -f 4`
echo $instanceId
echo "Showing Instance "$instanceId" Attributes..."
aws ec2 describe-instances --instance-id $instanceId --region $region --output table
echo "Stopping Instance "$instanceId"..."
aws ec2 stop-instances --instance-id $instanceId --region $region
echo "Terminating Instance "$instanceId"..."
aws ec2 terminate-instances --instance-id $instanceId --region $region
