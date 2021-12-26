data "aws_region" "current" {}

/*==== Jmeter Master Instance with Amazon linux image and ec2-user ======*/

resource "aws_instance" "jmeter-master-instance" {
  ami           = "${var.aws_ami}"
  instance_type = "${var.master_instance_type}"
  subnet_id     = "${var.master_subnet_ids[0]}"
  key_name      = "${aws_key_pair.jmeter-master-keypair.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.jmeter_master_iam_profile.name}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${var.security_group_ids}"]

  tags = {
    Name = "${var.resource_group}-jmeter-master"
    ResourceGroup = var.resource_group
  }


  connection {
    user = "ec2-user"
    host = self.public_ip
    private_key = "${file("${var.master_ssh_private_key_file}")}"
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo yum update -y",
      "sudo yum install -y java-1.8.0",
      "sudo yum remove -y java-1.7.0-openjdk",
      "sudo mkdir /jmeter-master",
      "mkdir ~/.aws",
      "touch ~/.aws/config",
      "sudo chown -R ec2-user /jmeter-master",
      "sudo yum install -y python3-pip python3 python3-setuptools -y",
      "sudo pip3 install boto3"
    ]
  }

  provisioner "file" {
    source = "${path.module}/master_start.sh"
    destination = "/jmeter-master/master_start.sh"
  }

  provisioner "file" {
    source = "${path.module}/load-test-script.jmx"
    destination = "/jmeter-master/load-test-script.jmx"
  }

  provisioner "file" {
    content = <<EOF
[default]
region=${data.aws_region.current.name}
  EOF
    destination = "/home/ec2-user/.aws/config"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /jmeter-master/",
      "curl ${var.jmeter3_url} > jMeter.tgz",
      "tar zxvf jMeter.tgz"
    ]
  }

  depends_on = [aws_autoscaling_group.jmeter-slave-ASG]
}


/*==== Jmeter Master Instance Pub File ======*/

resource "aws_key_pair" "jmeter-master-keypair" {
  key_name = "jmeter-master-keypair"
  public_key = "${file("${var.master_ssh_public_key_file}")}"
}



/*==== Jmeter Master IAM Role to fetch ELB DNS Name stored in SSM Parameter ======*/

resource "aws_iam_role" "jmeter_master_iam_role" {
    name = "jmeter_master_iam_role"
    path = "/"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF

  tags = {
    Name = "${var.resource_group}-jmeter-master-role"
    ResourceGroup = var.resource_group
  }

}

/*==== Role Policy ======*/

resource "aws_iam_policy" "policy" {
  name        = "SSMPolicy"
  description = "SSMPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters",
                "ssm:GetParameter",
                "ssm:GetParametersByPath"
            ],
            "Resource": "*"
        }
      ]
  })

  tags = {
    Name = "${var.resource_group}-jmeter-master-policy"
    ResourceGroup = var.resource_group
  }
      
}

/*==== Policy attachment to Role ======*/

resource "aws_iam_role_policy_attachment" "jmeter_master_iam_role_attachment1" {
      policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
      role = "${aws_iam_role.jmeter_master_iam_role.name}"    
}



resource "aws_iam_role_policy_attachment" "jmeter_master_iam_role_attachment2" {
    policy_arn = "${aws_iam_policy.policy.arn}"
    role = "${aws_iam_role.jmeter_master_iam_role.name}"    
}


/*==== Role attachment to Jmeter Master ======*/

resource "aws_iam_instance_profile" "jmeter_master_iam_profile" {
    name = "jmeter_master_iam_profile"
    role = "${aws_iam_role.jmeter_master_iam_role.name}"
}


/*==== Outputs ======*/

output "master_public_ip" {
  value = "${aws_instance.jmeter-master-instance.public_ip}"
}

output "master_private_ip" {
  value = "${aws_instance.jmeter-master-instance.private_ip}"
}
