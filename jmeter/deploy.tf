provider "aws" {
  region = "ap-northeast-1"
  shared_credentials_file = "/var/lib/jenkins/.aws/credentials"

}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "apache-jmeter-terraform-current-state"
    key            = "jmeter/s3/terraform.tfstate"
    region         = "ap-northeast-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "apache-jmeter-terraform-current-state-locks"
    encrypt        = true
  }
}

module "vpc" {
	source = "../shared/networking"
	vpc_name = "Jmeter"
	vpc_cidr = "10.219.129.0/24"
	public_subnets_cidr = ["10.219.129.0/26","10.219.129.64/26"]
	private_subnets_cidr = ["10.219.129.128/26","10.219.129.192/26"]
	resource_group = "VPC-Resource-Group"


}

module "security" {
	source = "./client-server-setup/networking"
	vpc_id = module.vpc.vpc_id
	jenkins_ip = "54.95.67.146/32"
	resource_group = "Jmeter-Resource-Group"


}
module "jmeter" {
	source = "./client-server-setup"
	vpc_id = module.vpc.vpc_id
	master_subnet_ids = module.vpc.public_subnet_ids
	client_subnet_ids = module.vpc.private_subnet_ids
	private_rtb_id = module.vpc.private_rtb_id
	public_rtb_id = module.vpc.public_rtb_id
	security_group_ids = module.security.sg_id
	master_ssh_public_key_file = "/var/lib/jenkins/keys/ec2-pem-tokyo.pub"
	master_ssh_private_key_file = "/var/lib/jenkins/keys/ec2-pem-tokyo.pem"
	slave_ssh_public_key_file  = "/var/lib/jenkins/keys/ec2-pem-tokyo.pub"
	resource_group = "Jmeter-Resource-Group"
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

output "master_public_ip" {
	value = module.jmeter.master_public_ip
}