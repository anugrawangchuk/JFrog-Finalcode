# Security Group for Public Instance
resource "aws_security_group" "public_sg" {
  name        = "public-instance-sg"
  description = "Allow all inbound traffic to the public instance"
  vpc_id      = var.vpc_id

  # Allow all inbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow to anywhere
  }

  tags = {
    Name = "PublicInstanceSG"
  }
}

# Security Group for Private Instance
resource "aws_security_group" "private_sg" {
  name        = "private-instance-sg"
  description = "Allow internal VPC communication for private instance"
  vpc_id      = var.vpc_id

  # Allow all inbound traffic (for testing purposes)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere (consider restricting this)
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow to anywhere
  }

  tags = {
    Name = "PrivateInstanceSG"
  }
}
