variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "eu-west-3"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for storing Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform_state"
}

variable "delete_noncurrent_version_days" {
  description = "Number of days after which to delete non-current versions"
  type        = number
  default     = 365
}
