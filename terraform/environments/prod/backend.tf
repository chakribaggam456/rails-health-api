terraform {
  backend "s3" {
    bucket         = "rails-health-api-tf-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "rails-health-api-tf-lock"
    encrypt        = true
  }
}