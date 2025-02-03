resource "aws_launch_configuration" "my_launch_config" {
  name          = "my-launch-configuration"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.ec2_sg.id]
  key_name      = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "hello from $(hostname -f)" > /var/www/html/index.html
              EOF

  lifecycle {
    create_before_destroy = true
  }
}