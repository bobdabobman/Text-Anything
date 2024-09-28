terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "app/terraform.tfstate"      # Unique key for the app
    region         = "eu-central-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}


