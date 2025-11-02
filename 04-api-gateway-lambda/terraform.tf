terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }
  }
  required_version = ">= 1.13"
}

provider "aws" {
  region = "us-east-1"
}