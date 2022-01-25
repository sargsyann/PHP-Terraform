terraform {
  backend "s3" {

    bucket         = "vzg-terraform-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "vzg-terraform-table"
    encrypt        = true 

  }
}
