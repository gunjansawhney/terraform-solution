
resource "aws_security_group" "elb_http" {
  name        = "elb_http_sg"
  description = "Allow traffic to instances through Elastic Load Balancer"
  vpc_id = var.vpc_id  

  ingress {
        from_port = "80"
        to_port   = "80"
        protocol  = "TCP"
        cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
        from_port = "0"
        to_port   = "0"
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "${var.resource_group}-sg"
    ResourceGroup = var.resource_group
  }
}


resource "aws_elb" "web_elb" {
  name = "${var.resource_group}-web-lb"
  security_groups = [
    aws_security_group.elb_http.id
  ]
  subnets = var.subnets
  internal = var.internal
  cross_zone_load_balancing = var.cross_zone_load_balancing

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 10
    interval = 30
    target = "HTTP:80/"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }

  tags = {
    Name = "${var.resource_group}-web-lb"
    ResourceGroup = var.resource_group
  }

}

