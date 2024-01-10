provider "aws" {
    region = "us-west-2"
}

# VPC
resource "aws_vpc" "notes-prod-vpc" {
    cidr_block = "10.0.0.0/16"
}

# Internet Gateway
resource "aws_internet_gateway" "notes-prod-gw" {
    vpc_id = aws_vpc.notes-prod-vpc.id
}

# Route Table
resource "aws_route_table" "notes-prod-rt" {
    vpc_id = aws_vpc.notes-prod-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.notes-prod-gw.id
    }

    route {
        ipv6_cidr_block        = "::/0"
        gateway_id = aws_internet_gateway.notes-prod-gw.id
    }
}

# Subnet
resource "aws_subnet" "notes-prod-subnet" {
    vpc_id = aws_vpc.notes-prod-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-west-2a"
    map_public_ip_on_launch = true
}

# Associate subnet with Route Table
resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.notes-prod-subnet.id
    route_table_id = aws_route_table.notes-prod-rt.id
}

# Security Group
resource "aws_security_group" "notes-prod-sg" {
    name        = "notes-prod-sg"
    description = "Allow inbound web traffic"
    vpc_id      = aws_vpc.notes-prod-vpc.id

    ingress {
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "MongoDB_Atlas"
        from_port   = 27017
        to_port     = 27017
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
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}