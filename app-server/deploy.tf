provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "apache-jmeter-terraform-current-state"
    key            = "app-server/s3/terraform.tfstate"
    region         = "ap-northeast-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "apache-jmeter-terraform-current-state-locks"
    encrypt        = true
  }
}


module "vpc" {
	source = "../shared/networking"
	resource_group = "VPC-Resource-Group"
}


module "load-balancer" {

	source = "../shared/load-balancer"
	vpc_id = module.vpc.vpc_id
	subnets = module.vpc.private_subnet_ids
	resource_group = "Apache-Resource-Group"
}


module "autoscaling" {
	
	source = "./autoscaling"
	vpc_id = module.vpc.vpc_id
	subnets = module.vpc.private_subnet_ids	
	private_rtb_id = module.vpc.private_rtb_id
	elb_id = module.load-balancer.elb_id
	elb_sg_id = module.load-balancer.sg_id
	elb_dns = module.load-balancer.elb_dns
	apache_public_key_file = "/var/lib/jenkins/keys/ec2-pem-tokyo.pub"
	resource_group = "Apache-Resource-Group"

}



/*========= Output ========*/


output "vpc_id" {
  value = module.vpc.vpc_id
}

output "account_id" {
  value = module.vpc.account_id
}


output "vpc_region" {
	value = module.vpc.region
}