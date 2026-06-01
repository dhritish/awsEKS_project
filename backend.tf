terraform {
  backend "s3" {
    bucket         = "leos3terra15042002"
    key            = "terraform/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
  }
}
