resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.resource_group}-${var.vpc_name}"
    ResourceGroup = var.resource_group
  }
}


/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.resource_group}-${var.vpc_name}-igw"
    ResourceGroup = var.resource_group
  }
}



/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr,count.index)
  availability_zone       = element(local.selected_availability_zones,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.resource_group}-${element(local.selected_availability_zones, count.index)}-${var.vpc_name}-public-subnet"
    ResourceGroup = var.resource_group
  }
}


/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(local.selected_availability_zones,   count.index)
  tags = {
    Name        = "${var.resource_group}-${element(local.selected_availability_zones, count.index)}-${var.vpc_name}-private-subnet"
    ResourceGroup = var.resource_group
  }
}


/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]

  tags = {
    Name        = "${var.resource_group}-${var.vpc_name}-eip"
    ResourceGroup = var.resource_group
  }
}


/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "${var.resource_group}-${var.vpc_name}-nat"
    ResourceGroup = var.resource_group
  }
}


/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.resource_group}-${var.vpc_name}-private-route-table"
    ResourceGroup = var.resource_group
  }
}


/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.resource_group}-${var.vpc_name}-public-route-table"
    ResourceGroup = var.resource_group
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}


/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}



