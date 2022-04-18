output "vpc_name" {
 value = aws_vpc.vpc.id
}

output "public_subnet_name" {
 value = aws_subnet.public-subnet-1.id
}
