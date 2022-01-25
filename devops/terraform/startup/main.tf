
resource "aws_s3_bucket" "s3" {
  bucket        = "vzg-terraform-bucket"
  force_destroy = true
  #
  versioning {
    enabled = true
  }
  #
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "dynamodb" {
  name         = "vzg-terraform-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  #
  attribute {
    name = "LockID"
    type = "S"
  }
}