resource "aws_db_subnet_group" "main" {
  name       = "depi-team-4-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "depi-team-4-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier                    = "depi-team-4-mysql"
  engine                        = "mysql"
  engine_version                = "8.0"
  instance_class                = "db.t3.micro"
  allocated_storage             = 20
  storage_type                  = "gp3"
  storage_encrypted             = true
  kms_key_id                    = aws_kms_key.data.arn
  db_name                       = "appdb"
  username                      = "admin"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.data.arn
  db_subnet_group_name          = aws_db_subnet_group.main.name
  vpc_security_group_ids        = [aws_security_group.rds.id]
  publicly_accessible           = false
  multi_az                      = false
  skip_final_snapshot           = true

  tags = {
    Name = "depi-team-4-mysql"
  }
}

# Encrypted S3 Application Data Bucket (KMS CMK + Block Public Access + HTTPS Only)
resource "aws_s3_bucket" "app_data" {
  bucket        = "depi-team-4-app-data-0481"
  force_destroy = true

  tags = {
    Name = "depi-team-4-app-data"
  }
}

resource "aws_s3_bucket_versioning" "app_data" {
  bucket = aws_s3_bucket.app_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  bucket = aws_s3_bucket.app_data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.data.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "app_data" {
  bucket                  = aws_s3_bucket.app_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "app_data" {
  bucket = aws_s3_bucket.app_data.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.app_data.arn,
        "${aws_s3_bucket.app_data.arn}/*"
      ]
      Condition = {
        Bool = { "aws:SecureTransport" = "false" }
      }
    }]
  })
}

output "rds_endpoint" {
  value = aws_db_instance.main.address
}

output "rds_secret_arn" {
  value = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "app_data_bucket_name" {
  value = aws_s3_bucket.app_data.bucket
}