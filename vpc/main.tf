terraform {
  required_providers{
      aws = {
          source = "hashicorp/aws"
          version = "~> 3.0"
      }
  }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "vpc" {
    cidr_block = var.vpc-cidr
    instance_tenancy = "default"
    tags = {
    Name = "Test VPC"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "Test IGW"
    }
}

resource "aws_subnet" "public-subnet-1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public-subnet-1-cidr
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
      Name = "Public Subnet 1"
    }
}

resource "aws_subnet" "public-subnet-2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public-subnet-2-cidr
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {
      Name = "Public Subnet 2"
    }
}

resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gateway.id
    }

    tags = {
        Name = "Public route table"
    }
}

resource "aws_route_table_association" "public-subnet-1-route-table-association" {
    subnet_id = aws_subnet.public-subnet-1.id
    route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public-subnet-2-route-table-association" {
    subnet_id = aws_subnet.public-subnet-2.id
    route_table_id = aws_route_table.public-route-table.id
}

resource "aws_subnet" "private-subnet-1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private-subnet-1-cidr
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false

    tags = {
      Name = "private Subnet 1 | App Tier"
    }
}

resource "aws_subnet" "private-subnet-2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private-subnet-2-cidr
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false

    tags = {
      Name = "private Subnet 2 | App Tier"
    }
}

resource "aws_subnet" "private-subnet-3" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private-subnet-3-cidr
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false

    tags = {
      Name = "private Subnet 3 | Database tier"
    }
}
resource "aws_subnet" "private-subnet-4" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private-subnet-4-cidr
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false

    tags = {
      Name = "private Subnet 4 | Database tier"
    }
}

resource "aws_eip" "nat_eip" {
    vpc = true
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public-subnet-1.id

    tags = {
      Name = "nat"
      Environment = "nat_for_prod_subnets"
    }
}

resource "aws_route_table" "private-route-table" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat.id
    }
    tags = {
      Name = "private route table"
    }
}


resource "aws_route_table_association" "private-subnet-1-route-table-asociation" {
  subnet_id = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "private-subnet-2-route-table-asociation" {
  subnet_id = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}
