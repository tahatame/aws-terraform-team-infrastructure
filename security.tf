resource "aws_security_group" "ec2_app" {
  name        = "depi-team-4-ec2-app-sg"
  description = "Least-privilege security group for EC2 app server (SSM only, no SSH)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from inside VPC only"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "Allow HTTPS outbound for SSM Agent and package updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow HTTP outbound for package updates"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow MySQL outbound to RDS inside VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "depi-team-4-ec2-app-sg"
  }
}

resource "aws_security_group" "rds" {
  name        = "depi-team-4-rds-sg"
  description = "Least-privilege security group for RDS MySQL (only from EC2 app SG)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL only from EC2 App Security Group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_app.id]
  }

  tags = {
    Name = "depi-team-4-rds-sg"
  }
}