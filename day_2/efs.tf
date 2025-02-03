// Add EFS resources
resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs"
  tags = {
    Name = "my-efs"
  }
}

resource "aws_efs_mount_target" "efs_mt1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.public1.id
  security_groups = [aws_security_group.private_sg.id]
}

resource "aws_efs_mount_target" "efs_mt2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.public2.id
  security_groups = [aws_security_group.private_sg.id]
}