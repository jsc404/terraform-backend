# terraform-backend

This repository contains the Terraform configuration to provision the infrastructure required for hosting Terraform state files on S3.

## Overview

This Terraform configuration sets up an S3 bucket for secure state storage with:

* Versioning
* Server-Side Encryption
* Public Access Block
* DynamoDB for locking
* IAM Policy for accessing S3 and DynamoDB
* Lifecycle Rules to delete non-current versions after a specified number of days
* Lifecycle Rule to abort incomplete multipart uploads after 7 days

**Requirements:**

* AWS Account with S3 & DynamoDB permissions
* Terraform installed

**Usage:**

1. Create `terraform.tfvars` and configure variables (replace placeholders):

    ```hcl
    aws_region          = "eu-west-3"
    s3_bucket_name      = "your-unique-bucket-name"
    dynamodb_table_name = "terraform_state"
    ```

2. Initialize & Apply Terraform:

    ```sh
    terraform init
    terraform apply
    ```

3. **Configure Terraform Backend:**

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