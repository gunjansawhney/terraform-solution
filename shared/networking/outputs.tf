/*==== VPC Output ======*/

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet.*.id
}

output "public_rtb_id" {
  value = aws_route.public_internet_gateway.*.id
}

output "private_rtb_id" {
  value = aws_route.private_nat_gateway.*.id
}


output "account_id" {
  value = data.aws_caller_identity.current.account_id
}


output "region" {
	value = data.aws_region.current.name
}