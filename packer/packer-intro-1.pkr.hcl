packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "intro1-ami"
  instance_type = "t2.micro"
  region        = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ubuntu"
     tags = {
    Name = "packer-test-ami1"
    
  }
}

build {
  name    = "intro1-ami"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

    provisioner "shell" {
        inline =["sudo apt update -y && sudo apt install nginx -y"]
    
  }
}
