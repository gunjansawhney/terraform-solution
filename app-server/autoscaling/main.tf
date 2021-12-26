/*==== Creating Security Group for the Apache Servers ======*/

resource "aws_security_group" "default" {
  name        = "${var.resource_group}-ec2-sg"
  description = "Security group to allow inbound/outbound on the EC2 servers"
  vpc_id      = var.vpc_id

  ingress {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          security_groups = ["${var.elb_sg_id}"]
        }

  ingress {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
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
    Name = "${var.resource_group}-ec2-sg"
    ResourceGroup = var.resource_group
  }
}


/*==== Pub file for Apache Servers ======*/

resource "aws_key_pair" "apache-keypair" {
  key_name = "apache-keypair"
  public_key = "${file("${var.apache_public_key_file}")}"
}



/*==== Creating Auto Scaling Group and it's launch configuration ======*/

resource "aws_launch_configuration" "web" {
  name_prefix = "${var.resource_group}-launch-config"
  image_id = var.image_id 
  instance_type = var.instance_type
  security_groups = [aws_security_group.default.id]
  associate_public_ip_address = var.associate_public_ip_address

  root_block_device {
    volume_type = "gp2"
    volume_size = 10
          
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = 2

  }

  ebs_block_device {
    device_name = "/dev/sdc"
    volume_type = "gp2"
    volume_size = 2

  }

  user_data = "${file("${path.module}/configure.sh")}"

  lifecycle {
    create_before_destroy = true
  }

  key_name = "${aws_key_pair.apache-keypair.key_name}"
}

/*==== ASG Creation ======*/

resource "aws_autoscaling_group" "web" {
  name = "${var.resource_group}-asg"

  min_size             = 2
  desired_capacity     = 2
  max_size             = 4
  
  health_check_type    = "EC2"
  load_balancers = [var.elb_id]

  launch_configuration = aws_launch_configuration.web.name


  vpc_zone_identifier  = var.subnets

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    propagate_at_launch = true
    key = "ResourceGroup"
    value = var.resource_group
  }

  tag {
    propagate_at_launch = true
    key = "Name"
    value = "${var.resource_group}-httpd-server"
  }

  depends_on = [var.private_rtb_id]

}


/*==== Creating SSM Parameter for the ELB DNS Name to be picked by Jmeter Server ======*/


resource "aws_ssm_parameter" "secret" {
  depends_on  = [var.elb_id]
  name        = "/loadbalancer/dns"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.elb_dns

}


