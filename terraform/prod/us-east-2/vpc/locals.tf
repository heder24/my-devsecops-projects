# locals {
#   name   = "prod" #"ex-${basename(path.cwd)}"
#   region = "eu-west-1"

#   vpc_cidr = "10.70.0.0/16"
#   azs      = slice(data.aws_availability_zones.available.names, 0, 3)

#   tags = {
#     Example    = local.name
#     GithubRepo = "heder-class-devops"
#     GithubOrg  = "fojiglobal"
#   }
# }