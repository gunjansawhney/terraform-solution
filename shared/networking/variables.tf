variable "resource_group" {  
    default = "RG-1"
}

variable "vpc_cidr" {   
    default = "10.251.184.0/24"
}


variable "public_subnets_cidr" {
	type = list(string)
	default = ["10.251.184.0/26","10.251.184.64/26"]

}

 variable "private_subnets_cidr" {
 	type = list(string)
 	default = ["10.251.184.128/26","10.251.184.192/26"]
 }


data "aws_availability_zones" "all" {
}

locals {
  sorted_availability_zones   = sort(data.aws_availability_zones.all.names)
  selected_availability_zones = [
    local.sorted_availability_zones[0],
    local.sorted_availability_zones[1],

  ]
}