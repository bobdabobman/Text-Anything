terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true                     # Enable encryption at rest
  }
}
