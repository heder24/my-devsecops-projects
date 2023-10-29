###################################### IAM #################################

module "iam-assumable-role" {
  source = "../../../modules/iam/modules/iam-assumable-role"
  

###############################
# Base-ec2-role IAM assumable role
###############################

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role             = true
  create_instance_profile = true

  role_name         = "base-ec2-role-1"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    
  ] 
}


module "iam_assumable_role_custom_trust_policy" {
  source = "../../../modules/iam/modules/iam-assumable-role"

  trusted_role_services = [
    "codedeploy.amazonaws.com"
  ]

  create_role = true

  role_name = "ec2-code-deploy-1"
  custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole",
    module.iam_policy.arn
  ]

}

#########################################
# IAM SNS policy
#########################################
module "iam_policy" {
  source = "../../../modules/iam/modules/iam-policy"

  name = "sns-publish-1"
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": "*"
        }
    ]
}
EOF
}
