#################### LT #####################
resource "aws_launch_template" "prod" {
  name = "${var.name}-lt"

  iam_instance_profile {
    name = data.aws_iam_instance_profile.prod_iam.name
  }

  image_id =  data.aws_ami.ubuntu.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = var.instance_type

  key_name = var.key_name

vpc_security_group_ids = [aws_security_group.private_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name}"
      Env  = var.environment
    }

  }
  tags = {
    Name = "${var.name}-lt"
  }
  user_data = filebase64("${path.module}/nginx.sh")
}
