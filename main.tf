# AWS region
provider "aws" {
  region = "ap-southeast-1"
}

# Specifies the required provider and version for the Terraform configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.14.0"
    }
  }

  # Specifies the minimum required Terraform version
  required_version = ">= 0.14.9"
}

