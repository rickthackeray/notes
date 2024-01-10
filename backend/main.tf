provider "aws" {
    region = "us-west-2"
}


# VPC
resource "aws_vpc" "notes-prod-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "notes-prod"
    } 
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

    tags = {
        Name = "notes-prod"
    }
}

# Subnet
resource "aws_subnet" "notes-prod-subnet" {
    vpc_id = aws_vpc.notes-prod-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-west-2a"
    map_public_ip_on_launch = true
}

# resource "aws_subnet" "notes-prod-subnet2" {
#     vpc_id = aws_vpc.notes-prod-vpc.id
#     cidr_block = "10.0.2.0/24"
#     availability_zone = "us-west-2b"
#     map_public_ip_on_launch = true
# }

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

    tags = {
        Name = "notes-prod"
    }
}

# Network interface
resource "aws_network_interface" "notes-prod-ni" {
    subnet_id       = aws_subnet.notes-prod-subnet.id
    private_ips     = ["10.0.1.50"]
    security_groups = [aws_security_group.notes-prod-sg.id]
}

# Elastic IP
resource "aws_eip" "notes-prod-eip" {
    domain = "vpc"
    network_interface = aws_network_interface.notes-prod-ni.id
    associate_with_private_ip = "10.0.1.50"
    depends_on = [ aws_internet_gateway.notes-prod-gw ]
}

# Server
resource "aws_instance" "notes-prod-ec2" {
    ami = "ami-0f53d557e55fc7064"
    instance_type = "t3.nano"
    availability_zone = "us-west-2a"
    key_name = "Key1"
    iam_instance_profile = "EC2allowECR"
    
    root_block_device {
        volume_size = 30
        volume_type = "gp3"
    }

    provisioner "file" {
        source = "keys.env"
        destination = "/home/ec2-user/keys.env"

        connection {
            type = "ssh"
            user = "ec2-user"
            private_key = "${file("/home/rick/Key1.pem")}"
            host = "${self.public_ip}"
        }
    }

    network_interface {
      network_interface_id = aws_network_interface.notes-prod-ni.id
      device_index = 0
    }

    user_data = filebase64("${path.module}/ec2.sh")

}

output "notes-prod-public_ip" {
    value = aws_instance.notes-prod-ec2.public_ip
}

