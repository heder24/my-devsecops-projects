################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../../modules/vpc"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]


  private_subnet_names = ["Private Subnet One", "Private Subnet Two"]
  # public_subnet_names omitted to show default name generation for all three subnets
  database_subnet_names    = ["DB Subnet One"]
  elasticache_subnet_names = ["Elasticache Subnet One", "Elasticache Subnet Two"]
  redshift_subnet_names    = ["Redshift Subnet One", "Redshift Subnet Two", "Redshift Subnet Three"]
  intra_subnet_names       = []

  create_database_subnet_group  = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true


  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = local.tags
}

##################################### SG #####################################

module "public_sg" {
  source = "../../modules/security groups"

  name        = var.public_sg 
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
   {
    description = "Allow HTTPS from public IPV4"
    from_port   = 443
    to_port     = 443
    protocol    = 6
    cidr_blocks = "0.0.0.0/0"
    
  },
   {
    description = "Allow HTTP from public IPV4"
    from_port   = 80
    to_port     = 80
    protocol    = 6
    cidr_blocks = "0.0.0.0/0"
    
  },

  ]

  ingress_with_ipv6_cidr_blocks = [
   {
    description      = "HTTPS from public IPV6"
    from_port        = 443
    to_port          = 443
    protocol         = 6
    ipv6_cidr_blocks = "::/0"
  },
   {
    description      = "HTTP from public IPV6"
    from_port        = 80
    to_port          = 80
    protocol         = 6
    ipv6_cidr_blocks = "::/0"
  },

  ]

  egress_with_cidr_blocks = [
   {
    description = "HTTPS to anywhere IPV4"
    from_port   = 443
    to_port     = 443
    protocol    = 6
    cidr_blocks = "0.0.0.0/0"
   },
    {
    description = "HTTP to anywhere IPV4"
    from_port   = 80
    to_port     = 80
    protocol    = 6
    cidr_blocks = "0.0.0.0/0"
   },
  ]

  egress_with_ipv6_cidr_blocks = [
 {
    description = "HTTP to anywhere IPV4"
    from_port   = 80
    to_port     = 80
    protocol    = 6
    ipv6_cidr_blocks = "::/0"
  },
 {
    description = "HTTPS to anywhere IPV4"
    from_port   = 443
    to_port     = 443
    protocol    = 6
    ipv6_cidr_blocks = "::/0"
  },

  ]

}


module "private_sg" {
  source = "../../modules/security groups"

  name        = var.private_sg 
  vpc_id      = module.vpc.vpc_id
 
  computed_ingress_with_source_security_group_id = [

    {
      from_port                = 22
      to_port                  = 22
      protocol                 = 6
      description              = "SSH from bastion"
      source_security_group_id = module.bastion_sg.security_group_id
    },
 
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = 6
      description              = "HTTPS"
       source_security_group_id = module.public_sg.security_group_id
    },
 

    {
      from_port                = 80
      to_port                  = 80
      protocol                 = 6
      description              = "HTTP"
      source_security_group_id = module.public_sg.security_group_id
    },

  ]
     number_of_computed_ingress_with_source_security_group_id = 3
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"

    },
  ]
 egress_with_ipv6_cidr_blocks = [
 {
    description = "HTTP to anywhere IPV4"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    ipv6_cidr_blocks = "::/0"
  },

 ]

}

module "bastion_sg" {
  source = "../../modules/security groups"

  name        = "prod-bastion-sg" 
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
   {
    description = "Allow SSH from public IPV4"
    from_port   = 22
    to_port     = 22
    protocol    = 6
    cidr_blocks = "0.0.0.0/0"
  },
  ]

  ingress_with_ipv6_cidr_blocks = [
   {
    description      = "Allow SSH from public IPV6"
    from_port        = 22
    to_port          = 22
    protocol         = 6
    ipv6_cidr_blocks = "::/0"

  },
  ]
 computed_egress_with_source_security_group_id = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = 6
      description              = "SSH"
      source_security_group_id = module.private_sg.security_group_id
    },
  ]
number_of_computed_egress_with_source_security_group_id = 1
}


###################################### IAM #################################

module "base-ec2-role" {
  source = "../../modules/iam/modules/iam-assumable-role"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role             = true
  create_instance_profile = true

  role_name         = var.base-role
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    
  ]
}

module "ec2-code-deploy" {
  source = "../../modules/iam/modules/iam-assumable-role"

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
  source = "../../modules/iam/modules/iam-policy"

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

########################################### ACM ##############################################

# locals {
#   # Use existing (via data source) or create new zone (will fail validation, if zone is not reachable)
#   use_existing_route53_zone = true

# }

module "acm" {
  source = "../../modules/acm"

  providers = {
    aws.acm = aws,
    aws.dns = aws
  }

  domain_name = local.domain_name
  zone_id     = local.zone_id
  

  subject_alternative_names = [
    "www.qa.${local.domain_name}",
    "www.stage.${local.domain_name}",
    "*.${local.domain_name}",
  ]

  tags = {
    Name = local.domain_name
  }
}

############################### Route53 Records #############################

module "dns_records" {
  source = "../../modules/route53/modules/records"
  zone_id = local.zone_id
   records = [
    {
      name = var.prod_domain_name
      full_name_override = true
      type = "A"
       alias = {
        name    = module.alb.lb_dns_name
        zone_id =  module.alb.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = var.qa_domain_name
      full_name_override = true
      type = "A"
       alias = {
        name    = module.alb.lb_dns_name
        zone_id =  module.alb.lb_zone_id
        evaluate_target_health = true
      }
    }, 
    {
      name = var.stage_domain_name
      full_name_override = true
      type = "A"
       alias = {
        name    = module.alb.lb_dns_name
        zone_id =  module.alb.lb_zone_id
        evaluate_target_health = true
      }
    },   
]
}

############################################ ALB ##############################################

##################################################################
# Application Load Balancer
##################################################################

module "alb" {
  source = "../../modules/alb"

  name = local.name

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  security_groups = [module.public_sg.security_group_id]
  
  http_tcp_listeners = [
 
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
      action_type        = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = ""
        status_code  = "404"
      }
    },

  ]

  https_listener_rules = [
    {
      https_listener_index = 0
      # priority             = 1
      actions = [
        {
          type       = "forward"
          target_group_index = 0
        }
      ]
      conditions = [{
        host_headers = [var.prod_domain_name, var.domain_name]

        
      }]
      
    },

{
      https_listener_index = 0
      # priority             = 1
      actions = [
        {
          type       = "forward"
          target_group_index = 0
        }
      ]
      conditions = [{
        host_headers = [var.stage_domain_name, var.host_header_stage_domain_name]

        
      }]
      
    },
{
      https_listener_index = 0
      # priority             = 1
      actions = [
        {
          type       = "forward"
          target_group_index = 0
        }
      ]
      conditions = [{
        host_headers = [var.qa_domain_name, var.host_header_qa_domain_name]

        
      }]
      
    },
  ]

   
  target_groups = [
    {
      name_prefix                       = "prod"
      backend_protocol                  = "HTTP"
      backend_port                      = 80
      target_type                       = "instance"
      deregistration_delay              = 10
      load_balancing_cross_zone_enabled = false
      health_check = {
        enabled             = true
        interval            = 30
        path                = var.health_path
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      


      tags = {
        InstanceTargetGroupTag = "prod"
      }
    },
  ]


  lb_tags = {
    MyLoadBalancer = "prod-lb"
  }

  https_listener_rules_tags = {
    MyLoadBalancerHTTPSListenerRule = "prod-listener"
  }

  https_listeners_tags = {
    MyLoadBalancerHTTPSListener = "prod-listener"
  }

  http_tcp_listeners_tags = {
    MyLoadBalancerTCPListener = "prod-listener"
  }
}

################################ ASG #############################

module "prod_asg" {
  source = "../../modules/autoscaling"

  # Autoscaling group
  name            = "${local.name}"
  use_name_prefix = false
  instance_name   = "prod-web"

  ignore_desired_capacity_changes = true

  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  default_instance_warmup   = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets

  # Launch template
  launch_template_name        = "lt-${local.name}"
  launch_template_description = "prod launch template"
  update_default_version      = true

  image_id          = data.aws_ami.ubuntu.id
  key_name = var.key_name
  instance_type     = "t2.micro"
  user_data         = base64encode(local.user_data)
  enable_monitoring = true
  create_iam_instance_profile = false
  iam_instance_profile_name = module.base-ec2-role.iam_instance_profile_id
  target_group_arns = module.alb.target_group_arns

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [module.private_sg.security_group_id]
    },

  ]

  placement = {
    availability_zone = "${local.region}b"
  }

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = { WhatAmI = "Instance" }
    },
    {
      resource_type = "volume"
      tags          = merge({ WhatAmI = "Volume" })
    },
 
  ]

  tags = local.tags
}

################################################################################
# EC2 Module
################################################################################

module "prod_bastion" {
  source = "../../modules/ec2"

  name = var.bastion
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro" # used to set core count below
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.bastion_sg.security_group_id]
  associate_public_ip_address = true
  disable_api_stop            = false
  key_name = var.key_name
  iam_instance_profile= module.base-ec2-role.iam_instance_profile_id
  create_iam_instance_profile = false
  # user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true
  tags = {
    Name = var.bastion
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.prod_bastion.id
  allocation_id = data.aws_eip.bastion_eip.id
}



