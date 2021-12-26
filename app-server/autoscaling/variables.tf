variable "vpc_id" { 
	description = "AWS Deployment region"  
}

variable "resource_group" {  
    default = "RG-1"
}

variable "elb_dns" {}

variable "subnets" {}

variable "elb_id" {}

variable "elb_sg_id" {}

variable "private_rtb_id" {}

variable "image_id" {
	default = "ami-0be4c0b05bbeb2afd"
}
  

variable "instance_type" {
	default = "t2.micro"
}


variable "associate_public_ip_address"{
	type = bool
	default = false
}

variable "apache_public_key_file" {
	description = "SSH public key filename for apache servers"
	default = "rg-resource-pem-tokyo.pub"
}



