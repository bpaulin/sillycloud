terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
  }
  backend "s3" {
    bucket = "bpaulin-devops-tf-backend"
    key    = "states/sillycloud.tfstate"
    region = "eu-west-3"
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

resource "aws_s3_bucket" "bucket-tf-backend" {
  bucket = "bpaulin-devops-tf-backend"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.bucket-tf-backend.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tf-backend.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.bucket-tf-backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.bucket-tf-backend.id
  versioning_configuration {
    status = "Enabled"
  }
}



# resource "aws_s3_bucket_acl" "bucket-tf-backend-acl" {
#   bucket = aws_s3_bucket.bucket-tf-backend.id
#   acl    = "private"
# }

# resource "aws_s3_bucket" "log_bucket" {
#   bucket = "bucket-tf-backend"
# }

# resource "aws_s3_bucket_acl" "log_bucket_acl" {
#   bucket = aws_s3_bucket.log_bucket.id
#   acl    = "log-delivery-write"
# }

# resource "aws_s3_bucket_logging" "bucket-tf-backend" {
#   bucket = aws_s3_bucket.bucket-tf-backend.id

#   target_bucket = aws_s3_bucket.bucket-tf-backend.id
#   target_prefix = "log/"
# }
