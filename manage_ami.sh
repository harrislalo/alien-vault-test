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
instanceId=`aws ec2 run-instances --image-id $ami --region $region |jq '.Instances[0].InstanceId' |tr -d '"'`
echo "Instance ID:"
echo $instanceId
echo "Showing Instance "$instanceId" Attributes..."
aws ec2 describe-instances --instance-id $instanceId --region $region --output table

#Running Status Code is 16
echo "Waiting for Instance "$instanceId" to be in running status..."
instanceStateCode=`aws ec2 describe-instances --instance-id $instanceId --region $region | jq '.Reservations[0].Instances[0].State.Code'`
while [ $instanceStateCode -ne "16" ]; do
  sleep 5
  instanceStateCode=`aws ec2 describe-instances --instance-id $instanceId --region $region | jq '.Reservations[0].Instances[0].State.Code'`
done
echo "Stopping Instance "$instanceId"..."
aws ec2 stop-instances --instance-id $instanceId --region $region

#Stopped Status Code is 80
echo "Waiting for Instance "$instanceId" to be in stopped status..."
instanceStateCode=`aws ec2 describe-instances --instance-id $instanceId --region $region | jq '.Reservations[0].Instances[0].State.Code'`
while [ $instanceStateCode -ne "80" ]; do
  sleep 5
  instanceStateCode=`aws ec2 describe-instances --instance-id $instanceId --region $region | jq '.Reservations[0].Instances[0].State.Code'`
done
echo "Terminating Instance "$instanceId"..."
aws ec2 terminate-instances --instance-id $instanceId --region $region
