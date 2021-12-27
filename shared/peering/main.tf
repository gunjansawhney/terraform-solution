provider "aws" {
  region = "ap-northeast-1"
  shared_credentials_file = "/var/lib/jenkins/.aws/credentials"
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



data "terraform_remote_state" "app-server" {
  backend = "s3"

  config = {
    # Replace this with your bucket name!
    bucket = "terraform-up-and-running-state-gsaw"
    key    = "app-server/s3/terraform.tfstate"
    region = "ap-northeast-1"
  }
}


data "terraform_remote_state" "jmeter" {
  backend = "s3"

  config = {
    # Replace this with your bucket name!
    bucket = "terraform-up-and-running-state-gsaw"
    key    = "jmeter/s3/terraform.tfstate"
    region = "ap-northeast-1"
  }
}


data "aws_vpc" "owner" {
	id = "${data.terraform_remote_state.app-server.outputs.vpc_id}"
}

data "aws_vpc" "accepter" {
	id = "${data.terraform_remote_state.jmeter.outputs.vpc_id}"
}

/*========= Requester's side of the connection. ============*/

resource "aws_vpc_peering_connection" "owner" {
  peer_owner_id = "${data.terraform_remote_state.app-server.outputs.account_id}"
  peer_vpc_id   = "${data.aws_vpc.accepter.id}"
  vpc_id = "${data.aws_vpc.owner.id}"
  peer_region = "${data.terraform_remote_state.app-server.outputs.vpc_region}"
  auto_accept   = false

  tags = {
  	Side = "Requester"
  }
}

/*============ Accepter's side of the connection.===========*/
resource "aws_vpc_peering_connection_accepter" "accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}


data "aws_route_tables" "owner" {
	vpc_id = "${data.terraform_remote_state.app-server.outputs.vpc_id}"
}

data "aws_route_tables" "accepter" {
	vpc_id = "${data.terraform_remote_state.jmeter.outputs.vpc_id}"
}

resource "aws_route" "owner" {
  for_each = "${data.aws_route_tables.owner.ids}"
  route_table_id              = each.value
  destination_cidr_block = "${data.aws_vpc.accepter.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.owner.id}"


}


resource "aws_route" "accepter" {
  for_each = "${data.aws_route_tables.accepter.ids}"
  route_table_id              = each.value
  destination_cidr_block = "${data.aws_vpc.owner.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.owner.id}"
}