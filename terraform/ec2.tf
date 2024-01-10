resource "aws_launch_template" "notes-prod-lt" {
    name_prefix = "notes-prod"
    image_id = "ami-0f53d557e55fc7064"
    instance_type = "t3.nano"
    key_name = "Key1"

    network_interfaces {
        security_groups = [aws_security_group.notes-prod-sg.id]
        subnet_id = aws_subnet.notes-prod-subnet.id
    }

    iam_instance_profile {
        name = "ecsInstanceRole"
    }

    block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
            volume_type = "gp3"
            volume_size = 30
        }
    }   
    user_data = filebase64("${path.module}/ec2.sh")
}

resource "aws_autoscaling_group" "notes-prod-asg" {
    name = "notes-prod-asg"
    max_size = 1
    min_size = 1
    desired_capacity = 1
    launch_template {
        id = aws_launch_template.notes-prod-lt.id
    }
}