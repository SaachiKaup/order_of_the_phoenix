terraform {
  backend "s3" {
    bucket       = "order-of-the-phoenix-tf-state"
    key          = "order-of-the-phoenix/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
