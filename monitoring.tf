# 1. S3 Bucket for VPC Flow Logs & Athena Query Results
resource "aws_s3_bucket" "flow_logs" {
  bucket        = "depi-team-4-flow-logs-0481"
  force_destroy = true

  tags = {
    Name = "depi-team-4-flow-logs"
  }
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  bucket                  = aws_s3_bucket.flow_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 2. VPC Flow Logs -> S3
resource "aws_flow_log" "vpc_s3" {
  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id

  tags = {
    Name = "depi-team-4-vpc-flow-logs"
  }
}

# 3. Glue Database & Athena Workgroup for Querying Flow Logs
resource "aws_glue_catalog_database" "flow_logs" {
  name = "depi_team_4_flow_logs_db"
}

resource "aws_athena_workgroup" "flow_logs" {
  name          = "depi-team-4-workgroup"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.flow_logs.bucket}/athena-results/"
    }
  }

  tags = {
    Name = "depi-team-4-workgroup"
  }
}

output "flow_logs_bucket_name" {
  value = aws_s3_bucket.flow_logs.bucket
}

output "athena_workgroup_name" {
  value = aws_athena_workgroup.flow_logs.name
}