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

source "amazon-ebs" "web-qa" {
  ami_name      = "packer-web-qa-${local.timestamp}"
  source_ami    = "ami-0430580de6244e02e"
  instance_type = "t2.micro"
  region        = "us-east-2"
  ssh_username  = "ubuntu"
  tags = {
    Name = "packer-web-qa-${local.timestamp}"
    Env  = "qa"
    OS   = "Ubuntu-20"
  }
}

build {
  name = "packer-web-qa"
  sources = [
    "source.amazon-ebs.web-qa"
  ]

  provisioner "ansible" {
    playbook_file    = "/home/cyber/repos/heder-class-devops/ansible/cloud/playbooks/web-qa.yml"
    ansible_env_vars = ["ANSIBLE_CONFIG=ansible.cfg"]
    extra_arguments  = ["-vvv"]
    user             = "ubuntu"
  }

}