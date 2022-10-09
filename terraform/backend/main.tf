terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_kms_key" "tf-backend" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "bucket-tf-backend" {
  bucket = "bpaulin-devops-tf-backend"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-tf-backen" {
  bucket = aws_s3_bucket.bucket-tf-backend.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tf-backend.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket-tf-backen" {
  bucket = aws_s3_bucket.bucket-tf-backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket-tf-backen" {
  bucket = aws_s3_bucket.bucket-tf-backend.id
  versioning_configuration {
    status = "Enabled"
  }
}
