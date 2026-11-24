resource "aws_wafv2_web_acl" "app" {
  name        = "depi-team-4-waf-acl"
  description = "Regional AWS WAF protecting DEPI Team 4 ALB against SQLi, XSS, and flooding"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Rule 1: Rate Limiting (block IPs exceeding 100 requests per 5 minutes)
  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "depi-team-4-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  # Rule 2: AWS Managed Common Rule Set (XSS, LFI, RFI, Bad Inputs)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "depi-team-4-common-rules"
      sampled_requests_enabled   = true
    }
  }

  # Rule 3: AWS Managed SQL Injection Rule Set (SQLi)
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "depi-team-4-sqli-rules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "depi-team-4-waf-acl"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "depi-team-4-waf-acl"
  }
}

output "waf_web_acl_arn" {
  value = aws_wafv2_web_acl.app.arn
}