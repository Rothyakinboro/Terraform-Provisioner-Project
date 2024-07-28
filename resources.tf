#ec2
resource "aws_instance" "provisioner-test" {
  ami                    = data.aws_ami.Provisioner-AMI.id
  instance_type          = "t2.medium"
  availability_zone      = "ca-central-1a"
  key_name               = "WemaDevOpsEC2"
  vpc_security_group_ids = [aws_security_group.provisioner-sg.id]
}

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

resource "null_resource" "Provision-null" {
    depends_on = [ time_sleep.Provisioner-Time-Delay ]
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
    inline = ["sudo yum -y update", "sudo yum install -y httpd", "sudo service httpd start", "echo '<!doctype html><html><body><h1>CONGRATS!!..You have configured successfully your remote exec provisioner!</h1></body></html>' | sudo tee /var/www/html/index.html"]
  }

}

resource "time_sleep" "Provisioner-Time-Delay" {
    depends_on = [ aws_instance.provisioner-test ]
    create_duration = "120s"  
}


 