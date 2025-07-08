// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "primary"
  region = var.AWS_PRIMARY_REGION

  default_tags {
    tags = {
      Application = var.APP
      Environment = var.ENV
      ManagedBy   = "Terraform"
      Repository  = "DAIVI"
    }
  }
}

provider "aws" {
  alias  = "secondary"
  region = var.AWS_SECONDARY_REGION

  default_tags {
    tags = {
      Application = var.APP
      Environment = var.ENV
      ManagedBy   = "Terraform"
      Repository  = "DAIVI"
    }
  }
}
