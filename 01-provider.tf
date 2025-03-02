terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

provider "aws" {
  alias  = "secondary"
  region = "ap-south-1"
}
