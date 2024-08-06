terraform {
  required_version = ">= 1.2.0"  # Replace with the desired version
}

# Provider configuration for AWS
provider "aws" {
  region = var.aws_region
}

# S3 bucket to store Terraform state
# CKV_AWS_18 - might generate excessive logs due to frequent state operations
# CKV2_AWS_62 - might lead to a high volume of notifications for state updates
# CKV_AWS_144 - Depending on your usecase consider addressing this.
# trunk-ignore(trivy/s3-bucket-logging)
# trunk-ignore(checkov/CKV2_AWS_62)
# trunk-ignore(checkov/CKV_AWS_144)
# trunk-ignore(checkov/CKV_AWS_145)
# trunk-ignore(checkov/CKV_AWS_18)
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Production"
  }
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled" # Versioning is recommended for state files
  }
}

# Configure server-side encryption for the S3 bucket
# trunk-ignore(trivy/AVD-AWS-0132)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

# Lifecycle configuration for S3 bucket
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "Manage S3 bucket lifecycle"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.delete_noncurrent_version_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# DynamoDB table for Terraform state locking
# point-in-time recovery and Table Encryption with KMS may be unneedet since the table is only used for a lock-marker
# trunk-ignore(trivy/AVD-AWS-0024)
# trunk-ignore(checkov/CKV_AWS_28)
# trunk-ignore(checkov/CKV_AWS_119)
# trunk-ignore(trivy/AVD-AWS-0025)
resource "aws_dynamodb_table" "terraform_state" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "Production"
  }
}

# IAM Policy for accessing S3 and DynamoDB
resource "aws_iam_policy" "terraform_state_access" {
  name        = "TerraformStateAccess"
  description = "Policy for Terraform to access S3 and DynamoDB for state management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.terraform_state.arn
      }
    ]
  })
}