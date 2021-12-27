provider "aws" {
  region = "ap-northeast-1"
  shared_credentials_file = "/var/lib/jenkins/.aws/credentials"

}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "apache-jmeter-terraform-current-state"

  # Enable versioning so we can see the full revision history of our state files
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


resource "aws_dynamodb_table" "terraform_locks" {
  name         = "apache-jmeter-terraform-current-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
