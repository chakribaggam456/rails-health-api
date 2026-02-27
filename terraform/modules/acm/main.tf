resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "api.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}