variable "prod_vpc_cidr" {
  type    = string
  default = "10.70.0.0/16"

}
variable "prod_vpc_instance_tenancy" {
  type    = string
  default = "default"
}


variable "vpc_cidr" {
  type    = string
  default = "10.70.0.0/16"
}


variable "vpc_tags" {
  type = map(string)
  default = {
    "Name"        = "prod"
    "Env"         = "prod"
    "Provisioner" = "Terraform"
  }
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "provisioner" {
  type    = string
  default = "Terraform"
}

variable "public_subnet_name" {
  type    = string
  default = "public-subnet"
}

variable "public_subnet_cidr_1" {
  type    = string
  default = "10.70.10.0/24"
}

variable "public_subnet_cidr_2" {
  type    = string
  default = "10.70.15.0/24"
}

variable "private_subnet_name" {
  type    = string
  default = "private-subnet"
}

variable "private_subnet_cidr_1" {
  type    = string
  default = "10.70.30.0/24"
}

variable "private_subnet_cidr_2" {
  type    = string
  default = "10.70.35.0/24"
}

variable "public_rt_name" {
  type    = string
  default = "public-rt"
}

variable "private_rt_name" {
  type    = string
  default = "private-rt"
}

variable "igw_name" {
  type    = string
  default = "igw"
}

#################### TG variables ####################
variable "port_80" {
  type    = number
  default = 80
}

variable "port_443" {
  type    = number
  default = 443
}

variable "proto_80" {
  type    = string
  default = "HTTP"

}

variable "proto_443" {
  type    = string
  default = "HTTPS"

}

variable "health_path" {
  type    = string
  default = "/health.html"

}

variable "instance_type" {
  type    = string
  default = "t2.micro"

}

variable "key_name" {
  type    = string
  default = "main-us-east-2"
}