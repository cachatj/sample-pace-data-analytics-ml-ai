// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {
  backend "s3" {
    bucket         = "###APP_NAME###-###ENV_NAME###-tfstate"
    key            = "sagemaker/vht-rag-chat-producer/terraform.tfstate"
    region         = "###AWS_PRIMARY_REGION###"
    dynamodb_table = "###APP_NAME###-###ENV_NAME###-tflock"
    encrypt        = true
  }
}
