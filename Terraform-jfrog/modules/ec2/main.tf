resource "aws_instance" "public_instance" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id
  associate_public_ip_address = true
  key_name = var.key_name

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "Public Instance"
  }
  # Attach public security group
  vpc_security_group_ids = [var.public_sg_id]
  
}

resource "aws_instance" "private_instance" {
  ami           = var.ami_id
  instance_type = "t2.medium"
  subnet_id     = var.private_subnet_id
  key_name = var.key_name

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "Private Instance"
  }

  # Attach private security group
  vpc_security_group_ids = [var.private_sg_id]
  
}
