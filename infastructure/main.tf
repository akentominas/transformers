resource "null_resource" "check_env_vars" {
  provisioner "local-exec" {
    command = "python ../support-files/env.py"
  }
}

resource "aws_vpc" "interview" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "transifex-demo-vpc"
  }
}

resource "aws_subnet" "transefix-demo-subnet" {
  vpc_id     = aws_vpc.interview.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "tranfefix-demo-subnet"
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.interview.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_launch_template" "ec2-blueprint" {
  name          = "ec2-autoscale-transifex"
  image_id      = var.EC2_AMI_ID
  instance_type = var.EC2_INSTANCE_TYPE
  #vpc_security_group_ids = [aws_security_group.allow_web.id]

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allow_web.id]
  }

}

resource "aws_autoscaling_group" "autoscaling-ec2-nginx" {
  desired_capacity = 2
  min_size         = 2
  max_size         = 3
  name             = "autoscaling-ec2-nginx"

  launch_template {
    id      = aws_launch_template.ec2-blueprint.id
    version = aws_launch_template.ec2-blueprint.latest_version
  }

  vpc_zone_identifier = [aws_subnet.transefix-demo-subnet.id]

}
