#!/bin/bash


Region="ap-northeast-1"
ASGName="Jmeter-Resource-Group-jmeter-slave-ASG"
SSMParameter="/loadbalancer/dns"
DNSToBeReplaced="google.com"
JMXFilePath="/jmeter-master/load-test-script.jmx"
JmeterPath="./apache-jmeter-3.3/bin/jmeter"
ResultJtlFileName="result.jtl"
ResultFolder="result"


private_ip=$(aws autoscaling describe-auto-scaling-instances --region $Region --output text --query "AutoScalingInstances[?AutoScalingGroupName=='$ASGName'].InstanceId" | xargs -n1 aws ec2 describe-instances --instance-ids $ID --region ap-northeast-1 --query "Reservations[].Instances[].PrivateIpAddress" --output text)

elb_dns=$(aws ssm get-parameter --name $SSMParameter --region $Region --query Parameter.Value --output text)

#sed -i 's/$DNSToBeReplaced/$elb_dns/g' $JMXFilePath

data_string="${private_ip[*]}"
echo "${data_string//${IFS:0:1}/,}" | xargs -i  $JmeterPath -n -t $JMXFilePath -R '{}' -l $ResultJtlFileName -e -o $ResultFolder 