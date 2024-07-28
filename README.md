# Terraform-Provisioner-Aws-Ec2-Instance-Provisioning-Using-Terraform-Provisioner.

## Project Description

This project leveraged Terraform Provisioner to provision an EC2 instance on AWS, sets up a security group to allow SSH (port 22) and HTTP (port 80) traffic, assigns a key-pair for SSH access, establishes a connection to the instance using its private IP, used "Time-sleep" to delaye the immediate running of remote-exec until EC2 Instance is created and then running a script on the instance after ensuring it has been created.

## Project Structure

1. Specify the Data Source for the AMI
2. Provision the EC2 Instance
3. Create the Security Group
4. Introduce a Time Delay
5. Configure the Null Resource for the Provisioner

Summary
This project automates the setup of an EC2 instance, security group, and key-pair, and runs a script to install and start an HTTP server. The time delay resource ensures the instance is fully created before the script runs, ensuring a smooth provisioning process.

```hcl
# Data Source: AMI
data "aws_ami" "Provisioner-AMI" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }
}

# EC2 Instance
resource "aws_instance" "provisioner-test" {
  ami                    = data.aws_ami.Provisioner-AMI.id
  instance_type          = "t2.medium"
  availability_zone      = "ca-central-1a"
  key_name               = "WemaDevOpsEC2"
  vpc_security_group_ids = [aws_security_group.provisioner-sg.id]
}

# Security Group
resource "aws_security_group" "provisioner-sg" {
  name = "Provisioner-SG"

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Time Delay
resource "time_sleep" "Provisioner-Time-Delay" {
  depends_on       = [aws_instance.provisioner-test]
  create_duration  = "120s"
}

# Null Resource for Provisioner
resource "null_resource" "Provision-null" {
  depends_on = [time_sleep.Provisioner-Time-Delay]
  triggers = {
    public_ip = aws_instance.provisioner-test.public_ip
  }

  connection {
    type        = "ssh"
    host        = aws_instance.provisioner-test.public_ip
    private_key = file("~/Downloads/WemaDevOpsEC2.pem")
    user        = "ec2-user"
    timeout     = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum install -y httpd",
      "sudo service httpd start",
      "echo '<!doctype html><html><body><h1>CONGRATS!!..You have configured successfully your remote exec provisioner!</h1></body></html>' | sudo tee /var/www/html/index.html"
    ]
  }
}
