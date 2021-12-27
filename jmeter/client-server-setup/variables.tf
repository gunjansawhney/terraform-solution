variable "resource_group" {}

variable "private_rtb_id" {}

variable "public_rtb_id" {}

variable "aws_ami" {
  description = "ID of AMI to use for the instances. IMPORTANT: Currently only Amazon Linux is supported!"
  default     = "ami-0ed9277fb7eb570c9"
}

variable "vpc_id" {
  description = "VPC ID where the cluster will be created"
}

variable "master_subnet_ids" {
  description = "The list of subnet IDs where the cluster will be created. Master node will be created in the first subnet mentioned in this list"
}

variable "client_subnet_ids"{
  description = "The list of subnet IDs where the cluster will be created. Clients nodes will be created in private subnets"
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate master instance with"
}


variable "master_instance_type" {
  description = "Instance type for master node"
  default     = "t2.medium"
}

variable "master_ssh_public_key_file" {
  description = "SSH public key filename for master node"
}

variable "master_ssh_private_key_file" {
  description = "SSH private key filename for master node"
}


variable "slave_instance_type" {
  description = "Instance type for slave nodes"
  default     = "t2.micro"
}

variable "slave_ssh_public_key_file" {
  description = "SSH public key filename for master node"
}


variable "slave_asg_size" {
  description = "Amount of working nodes in ASG"
  default     = "2"
}

variable "jmeter3_url" {
  description = "URL with jmeter archive"
  default     = "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-3.3.tgz"
}


