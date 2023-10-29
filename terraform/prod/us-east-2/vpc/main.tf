# ################################################################################
# # VPC Module
# ################################################################################

# module "vpc" {
#   source = "../../../modules/vpc"

#   name = local.name
#   cidr = local.vpc_cidr

#   azs             = local.azs
#   private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
#   public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]


#   private_subnet_names = ["Private Subnet One", "Private Subnet Two"]
#   # public_subnet_names omitted to show default name generation for all three subnets
#   database_subnet_names    = ["DB Subnet One"]
#   elasticache_subnet_names = ["Elasticache Subnet One", "Elasticache Subnet Two"]
#   redshift_subnet_names    = ["Redshift Subnet One", "Redshift Subnet Two", "Redshift Subnet Three"]
#   intra_subnet_names       = []

#   create_database_subnet_group  = false
#   manage_default_network_acl    = false
#   manage_default_route_table    = false
#   manage_default_security_group = false

#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   enable_nat_gateway = true
#   single_nat_gateway = true


#   # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
#   enable_flow_log                      = true
#   create_flow_log_cloudwatch_log_group = true
#   create_flow_log_cloudwatch_iam_role  = true
#   flow_log_max_aggregation_interval    = 60

#   tags = local.tags
# }

# # ###################################### IAM #################################

# # module "iam-assumable-role" {
# #   source = "../../modules/iam/modules/iam-assumable-role"


# #   ###############################
# #   # Base-ec2-role IAM assumable role
# #   ###############################

# #   trusted_role_services = [
# #     "ec2.amazonaws.com"
# #   ]

# #   create_role             = true
# #   create_instance_profile = true

# #   role_name         = "base-ec2-role-1"
# #   role_requires_mfa = false

# #   custom_role_policy_arns = [
# #     "arn:aws:iam::aws:policy/AmazonS3FullAccess",
# #     "arn:aws:iam::aws:policy/AmazonSSMFullAccess",

# #   ]
# # }

# # module "iam_assumable_role_custom_trust_policy" {
# #   source = "../../modules/iam/modules/iam-assumable-role"

# #   trusted_role_services = [
# #     "codedeploy.amazonaws.com"
# #   ]

# #   create_role = true

# #   role_name = "ec2-code-deploy-1"
# #   custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole",
# #     module.iam_policy.arn
# #   ]

# # }

# # #########################################
# # # IAM SNS policy
# # #########################################
# # module "iam_policy" {
# #   source = "../../modules/iam/modules/iam-policy"

# #   name = "sns-publish-1"
# #   path = "/"

# #   policy = <<EOF
# # {
# #     "Version": "2012-10-17",
# #     "Statement": [
# #         {
# #             "Effect": "Allow",
# #             "Action": "sns:Publish",
# #             "Resource": "*"
# #         }
# #     ]
# # }
# # EOF
# # }

# # # module "iam_assumable_role_custom_trust_policy" {
# # #   source = "../../modules/iam/modules/iam-assumable-role"

# # #   trusted_role_services = [
# # #     "codedeploy.amazonaws.com"
# # #   ]

# # #   create_role = true

# # #   role_name = "codepipeline.amazonaws.com"
# # #   custom_role_policy_arns = ["arn:aws:iam::312029113425:policy/service-role/AWSCodePipelineServiceRole-us-east-2-web-qa",
# # #   ]

# # # }