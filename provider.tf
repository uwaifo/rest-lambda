terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "localstack_url" {
  description = "Localstack endpoint"
  default     = "http://localhost:4566"
}

provider "aws" {
  secret_key = "mock_secret_key"
  access_key = "mock_access_key"

  region = "us-east-1"

  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = var.localstack_url
    cloudwatch     = var.localstack_url
    dynamodb       = var.localstack_url
    iam            = var.localstack_url
    lambda         = var.localstack_url
    s3             = var.localstack_url
    secretsmanager = var.localstack_url
    ses            = var.localstack_url
    sns            = var.localstack_url
    sqs            = var.localstack_url
    ssm            = var.localstack_url
    stepfunctions  = var.localstack_url
    sts            = var.localstack_url
  }
}
