variable "vpc_id" { 
	description = "AWS Deployment region"  
}

variable "subnets" {
	description = "A list of subnet IDs to attach to the ELB"
}

variable "resource_group" {  
    default = "RG-1"
}

variable "internal" {
  description = "If true, ELB will be an internal ELB"
  type        = bool
  default     = true
}

variable "cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

