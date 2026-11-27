variable "enable_macie" {
  description = "Enable Amazon Macie (requires AWS Paid Plan; set to true on paid accounts)"
  type        = bool
  default     = false
}

# 1. Enable Amazon Macie in the AWS Account
resource "aws_macie2_account" "main" {
  count                        = var.enable_macie ? 1 : 0
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}

# 2. One-Time Classification Job to Scan App Data S3 Bucket for Sensitive Data
resource "aws_macie2_classification_job" "app_data_scan" {
  count    = var.enable_macie ? 1 : 0
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
  value = var.enable_macie ? aws_macie2_classification_job.app_data_scan[0].id : "Disabled on AWS Free Plan (set -var enable_macie=true on Paid Plan)"
}