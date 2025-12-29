resource "aws_lb" "main" {
  name               = "${var.name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_groups
  subnets            = var.alb_subnets_id

  enable_deletion_protection = false

  tags = {
    Name        = "${var.name}-alb-${var.environment}"
  }
}

resource "aws_alb_target_group" "main" {
  name        = "${var.name}-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"


  tags = {
    Name        = "${var.name}-tg-${var.environment}"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

output "dns_name" {
  value = aws_lb.main.dns_name
}


output "aws_alb_target_group_arn" {
  value = aws_alb_target_group.main.arn
}
