resource "aws_autoscaling_group" "my_asg" {
  launch_configuration = aws_launch_configuration.my_launch_config.id
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.private1.id, aws_subnet.private2.id]
  target_group_arns    = [aws_lb_target_group.my_TG.arn]

  tag {
    key                 = "Name"
    value               = "my-auto-scaling-group"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 150

  lifecycle {
    create_before_destroy = true
  }
}