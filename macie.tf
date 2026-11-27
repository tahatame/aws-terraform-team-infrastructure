# 1. Enable Amazon Macie in the AWS Account
resource "aws_macie2_account" "main" {
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}

# 2. One-Time Classification Job to Scan App Data S3 Bucket for Sensitive Data
resource "aws_macie2_classification_job" "app_data_scan" {
  job_type = "ONE_TIME"
  name     = "depi-team-4-dlp-scan"

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [aws_s3_bucket.app_data.bucket]
    }
  }

  depends_on = [aws_macie2_account.main]

  tags = {
    Name = "depi-team-4-dlp-scan"
  }
}

output "macie_job_id" {
  value = aws_macie2_classification_job.app_data_scan.id
}