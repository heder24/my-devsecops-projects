

################### prod-TG-HTTP ##################
resource "aws_lb_target_group" "prod_tg_80" {
  name     = "${var.environment}-tg-80"
  port     = var.port_80
  protocol = var.proto_80
  vpc_id   = aws_vpc.prod.id
  health_check {
    path = var.health_path

  }
}

################### prod-TG-HTTPS ##################

resource "aws_lb_target_group" "prod_tg_443" {
  name     = "${var.environment}-tg-443"
  port     = var.port_443
  protocol = var.proto_443
  vpc_id   = aws_vpc.prod.id
  health_check {
    path = "/health.html"

  }
}

resource "aws_lb" "prod_lb" {
  name               = "${var.environment}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]


  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_listener" "prod_443" {
  load_balancer_arn = aws_lb.prod_lb.arn
  port              = var.port_443
  protocol          = var.proto_443
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.hederdevops_ssl_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_tg_80.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.prod_lb.arn
  port              = var.port_80
  protocol          = var.proto_80

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "prod" {
  listener_arn = aws_lb_listener.prod_443.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_tg_80.arn
  }

  condition {
    host_header {
      values = ["www.hederdevops.com", "hederdevops.com"]
    }
  }
}
