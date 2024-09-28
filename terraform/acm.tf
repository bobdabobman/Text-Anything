# Create certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = "my-acm-cert"
  }
}

# Allow it to be referencable
data "aws_acm_certificate" "cert" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
  most_recent = true
}
