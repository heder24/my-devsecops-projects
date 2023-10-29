data "aws_route53_zone" "heder_lab_zone" {
  name         = "hederdevops.com."
  
}

output "zone_id" {
    value = data.aws_route53_zone.heder_lab_zone.id
  
}

data "aws_ami" "web_stage_ami" {
  most_recent      = true
  

  filter {
    name   = "tag:Name"
    values = ["packer-web-stage-*"]
  }
}

output "prod_ami" {
    value = data.aws_ami.web_stage_ami.id
  
}

data "aws_acm_certificate" "hederdevops_ssl_cert" {
  domain      = "www.dev.hederdevops.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

################## ASG ###################
data "aws_iam_instance_profile" "prod_iam" {
  name = "base-ec2-role"
}
output "iam_name" {
    value = data.aws_iam_instance_profile.prod_iam.arn
  
}

data "aws_key_pair" "prod_key" {
    key_name = "main-us-east-2"
}

output "key_name" {
  value = data.aws_key_pair.prod_key.arn
}

  ################## ASG ###################
data "aws_iam_instance_profile" "prod_iam" {
  name = "base-ec2-role"
}
output "iam_name" {
  value = data.aws_iam_instance_profile.prod_iam.arn

}

data "aws_key_pair" "prod_key" {
  key_name = "main-us-east-2"
}

output "key_name" {
  value = data.aws_key_pair.prod_key.arn
}

################ Ubuntu AMI lookup ###################

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

output "ami_id" {

  value = data.aws_ami.ubuntu.id
}


