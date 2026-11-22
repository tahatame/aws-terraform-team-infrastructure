data "aws_caller_identity" "current" {}

# 1. Customer Managed Key (CMK) for Data Services (RDS, S3, Secrets Manager)
resource "aws_kms_key" "data" {
  description             = "DEPI Team 4 CMK for Data at Rest (RDS, S3, Secrets Manager)"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootAccountPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowAWSDataServicesViaService"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              "rds.us-east-1.amazonaws.com",
              "s3.us-east-1.amazonaws.com",
              "secretsmanager.us-east-1.amazonaws.com"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name = "depi-team-4-data-cmk"
  }
}

resource "aws_kms_alias" "data" {
  name          = "alias/depi-team-4-data-cmk"
  target_key_id = aws_kms_key.data.key_id
}

# 2. Customer Managed Key (CMK) for Compute Storage (EC2 EBS Volumes)
resource "aws_kms_key" "ebs" {
  description             = "DEPI Team 4 CMK for EC2 EBS Volume Encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootAccountPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowEC2EBSViaService"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ec2.us-east-1.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "depi-team-4-ebs-cmk"
  }
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/depi-team-4-ebs-cmk"
  target_key_id = aws_kms_key.ebs.key_id
}

output "kms_data_key_arn" {
  value = aws_kms_key.data.arn
}

output "kms_ebs_key_arn" {
  value = aws_kms_key.ebs.arn
}