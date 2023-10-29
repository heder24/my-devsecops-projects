packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-web-base"
  source_ami    = "ami-0430580de6244e02e"
  instance_type = "t2.micro"
  region        = "us-east-2"
  ssh_username  = "ubuntu"
    tags = {
    Name = "packer-test-ami"
    
  }
}

build {
  name = "packer-intro"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
	  inline =["sudo apt update -y && sudo apt install nginx -y"]
   
  }
}
