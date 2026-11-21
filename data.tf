resource "aws_db_subnet_group" "main" {
  name       = "depi-team-4-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "depi-team-4-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier                  = "depi-team-4-mysql"
  engine                      = "mysql"
  engine_version              = "8.0"
  instance_class              = "db.t3.micro"
  allocated_storage           = 20
  storage_type                = "gp3"
  storage_encrypted           = true
  db_name                     = "appdb"
  username                    = "admin"
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.main.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  publicly_accessible         = false
  multi_az                    = false
  skip_final_snapshot         = true

  tags = {
    Name = "depi-team-4-mysql"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.main.address
}

output "rds_secret_arn" {
  value = aws_db_instance.main.master_user_secret[0].secret_arn
}