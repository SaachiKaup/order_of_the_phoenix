terraform {
  backend "s3" {
    bucket         = "order-of-the-phoenix-tf-state"
    key            = "order-of-the-phoenix/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "order-of-the-phoenix-tf-locks"
  }
}
