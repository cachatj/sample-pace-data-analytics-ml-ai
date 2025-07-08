// Copyright 2025 Amazon.com and its affiliates; all rights reserved.
// This file is Amazon Web Services Content and may not be duplicated or distributed without permission.

terraform {

  backend "s3" {

    bucket         = "vhtds-dev-tf-back-end-263704881331-us-east-1"
    key            = "dev/datalakes/stocks/terraform.tfstate"
    dynamodb_table = "vhtds-dev-tf-back-end-lock"
    region         = "us-east-1"
    encrypt        = true
  }
}
