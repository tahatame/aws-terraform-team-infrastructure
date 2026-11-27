# Incident Response Quarantine Security Group
# Intentionally has NO ingress and NO egress rules to completely isolate a compromised EC2 instance
resource "aws_security_group" "quarantine" {
  name        = "depi-team-4-ir-quarantine-sg"
  description = "Incident Response quarantine SG - blocks all inbound and outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name    = "depi-team-4-ir-quarantine-sg"
    Purpose = "IncidentResponse"
  }
}

output "quarantine_sg_id" {
  value = aws_security_group.quarantine.id
}