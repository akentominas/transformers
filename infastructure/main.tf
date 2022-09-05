resource "null_resource" "check_env_vars" {
  provisioner "local-exec" {
    command = "python ../support-files/env.py"
  }
}

resource "aws_vpc" "interview" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "transifex-demo-vpc"
  }
}

resource "aws_subnet" "transefix-demo-subnet" {
  vpc_id                  = aws_vpc.interview.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "tranfefix-demo-subnet"
  }
}

# Creating an Internet Gateway to communicate over internet. I was not able to ssh into the nodes.
resource "aws_internet_gateway" "transifex-demo-gtw" {
  vpc_id = aws_vpc.interview.id
}

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

resource "aws_route_table_association" "transifex-rt-public-subnet" {
  subnet_id      = aws_subnet.transefix-demo-subnet.id
  route_table_id = aws_route_table.transidex-route-table.id
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


resource "aws_launch_configuration" "launch-config" {

  image_id      = var.EC2_AMI_ID
  instance_type = var.EC2_INSTANCE_TYPE

  security_groups = [aws_security_group.allow_web.id]

  key_name = "access-key"

  user_data = <<-EOF
                 #!/bin/bash
                 sudo apt update
                 sudo apt install nginx -y
                 printf '<body style="margin: 0 auto; font-family: Tahoma, Verdana, Arial, sans-serif;">\n<h1>Welcome to Transifex!</h1>\n<p>If you see this page, you are hired! &#128512;</p>\n<body>' > /var/www/html/index.nginx-debian.html
                 sudo systemctl restart nginx
                 EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscaling-ec2-nginx" {
  launch_configuration = aws_launch_configuration.launch-config.name
  desired_capacity     = 2
  min_size             = 2
  max_size             = 3
  name                 = "autoscaling-ec2-nginx"

  vpc_zone_identifier = [aws_subnet.transefix-demo-subnet.id]

}
