# Output the name of the DynamoDB table
output "aws_dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_state.name
  description = "The name of the DynamoDB table for state locking"
}

# Output the ARN of the S3 bucket
output "aws_s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket for storing Terraform state"
}

# Output the name of the S3 bucket
output "aws_s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "The name of the S3 bucket for storing Terraform state"
}