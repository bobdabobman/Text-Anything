terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "terraform/terraform.tfstate"
    region         = "eu-central-1"           # eu regulations?
    dynamodb_table = "terraform-lock-table"
    encrypt        = true                     # Enable encryption at rest
  }
}
