resource "aws_lb" "private_lb" {
  name               = "private-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.public_sg_id]
  subnets            = var.private_subnet_ids

  tags = {
    Name = "private-lb"
  }
}

resource "aws_lb_target_group" "private_tg" {
  name     = "private-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
  }
}

resource "aws_lb_listener" "private_listener" {
  load_balancer_arn = aws_lb.private_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "private" {
  count = length(var.private_instance_ids)

  target_group_arn = aws_lb_target_group.private_tg.arn
  target_id        = var.private_instance_ids[count.index]
  port             = 80
}