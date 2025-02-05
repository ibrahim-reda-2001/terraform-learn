resource "aws_instance" "public" {
  count = length(var.public_subnet_ids)

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[count.index]
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = var.key_name
  user_data              = var.public_user_data

  tags = {
    Name = "public-instance-${count.index + 1}"
  }
}

resource "aws_instance" "private" {
  count = length(var.private_subnet_ids)

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = var.key_name
  user_data              = var.private_user_data

  tags = {
    Name = "private-instance-${count.index + 1}"
  }
}