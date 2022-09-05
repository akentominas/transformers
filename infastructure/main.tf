resource "null_resource" "check_env_vars" {
  provisioner "local-exec" {
    command = "python ../support-files/env.py"
  }
}

# Creating the VPC where the linux instances will live
resource "aws_vpc" "interview" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "transifex-demo-vpc"
  }
}

# Creating a public subnet for the instances to communicate over internet
resource "aws_subnet" "transefix-demo-subnet" {
  vpc_id                  = aws_vpc.interview.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "tranfefix-demo-subnet"
  }
}

# Creating an Internet Gateway for the VPC to communicate over internet. I was not able to ssh into the nodes.
resource "aws_internet_gateway" "transifex-demo-gtw" {
  vpc_id = aws_vpc.interview.id
}

# Creating routing table for the public subnets to reach to the internet
resource "aws_route_table" "transidex-route-table" {
  vpc_id = aws_vpc.interview.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.transifex-demo-gtw.id
  }

  tags = {
    Name = "transifex-route-table"
  }
}

# Associating the route table with the public subnet that was created
resource "aws_route_table_association" "transifex-rt-public-subnet" {
  subnet_id      = aws_subnet.transefix-demo-subnet.id
  route_table_id = aws_route_table.transidex-route-table.id
}

# Creating security group in order to control web traffic
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
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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

# Creating and storing the SSH keys which will be assigned to the EC2 instances
resource "tls_private_key" "transifex" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.TLS_PRIVATE_KEY_NAME
  public_key = tls_private_key.transifex.public_key_openssh
}

# Creating a launch configuration
# It is used by autoscaling groups, and it provides the resources which will be created
resource "aws_launch_configuration" "launch-config" {

  image_id      = var.EC2_AMI_ID
  instance_type = var.EC2_INSTANCE_TYPE

  security_groups = [aws_security_group.allow_web.id]

  key_name = aws_key_pair.generated_key.key_name

  user_data = <<-EOF
                 #!/bin/bash
                 sudo apt update
                 sudo apt install nginx -y
                 printf '<body style="margin: 0 auto; font-family: Tahoma, Verdana, Arial, sans-serif; text-align: center; padding: 100px;">\n<h1>Welcome to Transifex!</h1>\n<p>If you see this page, you are hired! &#128512;</p>\n<body>' > /var/www/html/index.nginx-debian.html
                 sudo systemctl enable nginx
                 sudo systemctl restart nginx
                 EOF
  lifecycle {
    create_before_destroy = true
  }
}

# Creating an Elastic LB which then will be attached to the Autoscaling Group
resource "aws_elb" "transifex-lb" {
  name            = "transifex-lb"
  subnets         = [aws_subnet.transefix-demo-subnet.id]
  security_groups = [aws_security_group.allow_web.id]
  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
}


resource "aws_autoscaling_group" "autoscaling-ec2-nginx" {
  launch_configuration = aws_launch_configuration.launch-config.name
  load_balancers       = [aws_elb.transifex-lb.name]
  desired_capacity     = 2
  min_size             = 2
  max_size             = 3
  name                 = "autoscaling-ec2-nginx"
  vpc_zone_identifier  = [aws_subnet.transefix-demo-subnet.id]

}
