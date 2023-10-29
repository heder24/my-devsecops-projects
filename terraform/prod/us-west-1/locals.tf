locals {
  name   = "prod" #"ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.80.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Name    = local.name
    GithubRepo = "heder-class-devops"
    GithubOrg  = "hederdevops"
  }
# domain_name = "hederdevops.com"
  user_data = <<-EOT
    #!/bin/bash
    sudo apt update -y 
    sudo apt install nginx -y 
    echo "Welcome to My Default Page. Please Deploy Your App" >> /var/www/html/index.html
    echo "My Health Page" >> /var/www/html/health.html
  EOT
 domain = var.domain_name
  domain_name = local.domain
  zone_id= data.aws_route53_zone.heder_lab_zone.id
}


