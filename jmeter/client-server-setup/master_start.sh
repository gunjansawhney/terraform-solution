#!/bin/bash


Region="us-east-1"
ASGName="Jmeter-Resource-Group-jmeter-slave-ASG"
SSMParameter="/loadbalancer/dns"
DNSToBeReplaced="google.com"
JmeterFolder='/jmeter-master'
JMXFilePath="/jmeter-master/load-test-script.jmx"
JmeterPath="./apache-jmeter-3.3/bin/jmeter"
ResultJtlFileName="result.jtl"
ResultFolder="result"


private_ip=$(aws autoscaling describe-auto-scaling-instances --region $Region --output text --query "AutoScalingInstances[?AutoScalingGroupName=='$ASGName'].InstanceId" | xargs -n1 aws ec2 describe-instances --instance-ids $ID --region $Region --query "Reservations[].Instances[].PrivateIpAddress" --output text)

elb_dns=$(aws ssm get-parameter --name $SSMParameter --region $Region --query Parameter.Value --output text)

sed -i 's/$DNSToBeReplaced/$elb_dns/g' $JMXFilePath

rm -f "$JmeterFolder/$ResultJtlFileName"
rm -rf "$JmeterFolder/$ResultFolder"


data_string="${private_ip[*]}"
echo "${data_string//${IFS:0:1}/,}" | xargs -i  $JmeterPath -n -t $JMXFilePath -R '{}' -l $JmeterFolder/$ResultJtlFileName 

 $JmeterPath -g $JmeterFolder/$ResultJtlFileName  -o $JmeterFolder/$ResultFolder

 aws s3 cp $JmeterFolder/$ResultFolder/ s3://apache-jmeter-results/ --recursive
