/*==== Jmeter Clients Auto Scaling Group's Launch Configuration ======*/

resource "aws_launch_configuration" "jmeter-slave-lc" {
  name_prefix   = "${var.resource_group}-jmeter-slave-lc"
  image_id      = "${var.aws_ami}"
  instance_type = "${var.slave_instance_type}"

  user_data = <<EOF
    #!/bin/sh
    yum update -y
    yum install -y java-1.8.0
    yum remove -y java-1.7.0-openjdk
    mkdir /jmeter-client
    cd /jmeter-client
    curl ${var.jmeter3_url} > jMeter.tgz
    tar zxvf jMeter.tgz
    nohup ./apache-jmeter-3.3/bin/jmeter-server &
  EOF

  security_groups = ["${var.security_group_ids}"]
  key_name        = "${aws_key_pair.jmeter-slave-keypair.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

/*==== Jmeter Clients Auto Scaling Group ======*/

resource "aws_autoscaling_group" "jmeter-slave-ASG" {
  name                 = "${var.resource_group}-jmeter-slave-ASG"
  max_size             = "${var.slave_asg_size}"
  min_size             = "${var.slave_asg_size}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.jmeter-slave-lc.name}"
  vpc_zone_identifier  = var.client_subnet_ids

  tag {
    key                 = "Name"
    value               = "${var.resource_group}-jmeter-slave"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "ResourceGroup"
    value               = "${var.resource_group}"
    propagate_at_launch = "true"
  }

  depends_on = [var.private_rtb_id]
}


/*==== Jmeter Client Instance Pub File ======*/

resource "aws_key_pair" "jmeter-slave-keypair" {
  key_name = "jmeter-slave-keypair"
  public_key = "${file("${var.slave_ssh_public_key_file}")}"
}





