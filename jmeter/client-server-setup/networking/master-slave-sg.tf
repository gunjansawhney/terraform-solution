/*==== Security Group for Jmeter servers ======*/

resource "aws_security_group" "commong_sg" {
  name        = "${var.resource_group}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = var.vpc_id

  ingress {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          self        = "true"
        }
  ingress {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["103.43.112.97/32"]
        }
  
  ingress {
          from_port   = "0"
          to_port     = "0"
          protocol    = "-1"
          self        = "true"
        }

  egress {
        from_port = "0"
        to_port   = "0"
        protocol  = "-1"
        self      = "true"

        }
  egress {
        from_port = "443"
        to_port   = "443"
        protocol  = "TCP"
        cidr_blocks = ["0.0.0.0/0"]

        }
  egress {
        from_port = "80"
        to_port   = "80"
        protocol  = "TCP"
        cidr_blocks = ["0.0.0.0/0"]

        }

  tags = {
    ResourceGroup = var.resource_group
  }
}


/*==== Output ======*/

output "sg_id" {
  value = aws_security_group.commong_sg.id
}