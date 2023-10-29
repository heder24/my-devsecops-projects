packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "web-stage" {
  ami_name      = "packer-web-stage-${local.timestamp}"
  source_ami    = "ami-0430580de6244e02e"
  instance_type = "t2.micro"
  region        = "us-east-2"
  ssh_username  = "ubuntu"
  tags = {
    Name = "packer-web-stage-${local.timestamp}"
    Env  = "stage"
    OS   = "Ubuntu-20"
  }
}

build {
  name = "packer-web-stage"
  sources = [
    "source.amazon-ebs.web-stage"
  ]

  provisioner "ansible" {
    playbook_file    = "/home/cyber/repos/heder-class-devops/ansible/cloud/playbooks/web-stage.yml"
    ansible_env_vars = ["ANSIBLE_CONFIG=ansible.cfg"]
    extra_arguments  = ["-vvv"]
    user             = "ubuntu"
  }

}