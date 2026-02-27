output "certificate_arn" {
  value = aws_acm_certificate.this.arn
}

output "validation_records" {
  value = aws_acm_certificate.this.domain_validation_options
}