data "aws_ami" "Provisioner-AMI" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "root-device-name"
    values = ["/dev/xvda"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "boot-mode"
    values = ["uefi-preferred"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
