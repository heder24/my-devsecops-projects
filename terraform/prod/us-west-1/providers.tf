terraform {
  cloud {
    organization = "heder24"

    workspaces {
      name = "prod-us-west-1-infrastucture"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-1"
}