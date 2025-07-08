// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {

  backend "s3" {

    bucket         = "vhtds-dev-tf-back-end-263704881331-us-east-1"
    key            = "dev/z-etl/dynamodb/db-data-prereq/terraform.tfstate"
    dynamodb_table = "vhtds-dev-tf-back-end-lock"
    region         = "us-east-1"
    encrypt        = true
  }
}
