terraform {
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

resource "aws_s3_bucket" "bucket-tf-backend" {
  bucket = "bpaulin-devops-tf-backend"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.bucket-tf-backend
  versioning_configuration {
    status = "Enabled"
  }
}
