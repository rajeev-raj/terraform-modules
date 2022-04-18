terraform {
  required_providers{
      aws = {
          source = "hashicorp/aws"
          version = "~> 3.0"
      }
  }
}

/*
data "aws_vpc" "main" {
  tags = {
    Environment = "Test VPC"
  }
}


data "aws_subnet" "main_subnet" {
  tags = {
    Environment = "Public Subnet 1"
  }
}

*/

module "vpc_data" {
  source = "../vpc"
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc_data.vpc_name

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "app_server" {
    ami           = var.ami_name
    instance_type = var.inst_type
    //vpc_id = data.aws_vpc.selected.id
    subnet_id     = module.vpc_data.public_subnet_name
    vpc_security_group_ids = [aws_security_group.allow_tls.id]
    user_data    = <<EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y nginx vim
    sudo cat > /var/www/html/hello.html <<EOD
    Hello world!
    EOD
    EOF
    
    tags = {
        Name = "EampleAppServerInstance"
    } 
}

