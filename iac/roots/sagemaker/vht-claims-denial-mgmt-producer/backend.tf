// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {
  backend "s3" {
    bucket         = "vhtds-dev-tfstate"
    key            = "sagemaker/vht-claims-denial-mgmt-producer/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "vhtds-dev-tflock"
    encrypt        = true
  }
}
