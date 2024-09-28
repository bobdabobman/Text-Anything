data "aws_acm_certificate" "cert" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

variable "domain_name" {
  description = "The domain name to use for the certificate"
  default     = "text18449410220anything.com"
}
