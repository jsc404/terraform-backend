# terraform-backend

This repository contains a Terraform template to provision the infrastructure required for hosting Terraform state files securely on S3.

## Overview

This configuration sets up an S3 bucket for secure state storage with:

- Versioning
- Server-Side Encryption (SSE-S3)
- Public Access Block
- DynamoDB for locking
- IAM Policy for accessing S3 and DynamoDB
- Lifecycle Rules for versioning and incomplete multipart uploads management

**Note:** If you require Server-Side Encryption with Customer-Managed Keys (SSE-KMS), you'll need to adapt the configuration accordingly.

**Requirements:**

- AWS Account with S3 & DynamoDB permissions
- Terraform installed

**Usage:**

1. **Clone this repository:**

   ```sh
   git clone https://github.com/u8717/terraform-backend.git
   cd terraform-backend
   ```

2. Create `terraform.tfvars` and configure variables (replace placeholders):

   ```hcl
   aws_region          = "eu-west-3"
   s3_bucket_name      = "your-unique-bucket-name"
   dynamodb_table_name = "terraform_state"
   ```

3. Initialize & Apply Terraform:

   ```sh
   terraform init
   terraform apply
   ```

4. **Configure Terraform Backend:**

   After the resources are created, configure your Terraform backend to use the newly created S3 bucket and DynamoDB table. Add the following block to your Terraform configuration:

   ```hcl
   terraform {
     backend "s3" {
       bucket         = "your-unique-bucket-name" # Replace with your bucket name
       key            = "path/to/your/terraform.tfstate" # Replace with your state file path
       dynamodb_table = "terraform_state"
       region         = "eu-west-3"
       encrypt        = true
     }
   }
   ```
