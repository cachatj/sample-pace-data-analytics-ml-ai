// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "project_id" {
  description = "The ID of the SageMaker project"
  value       = module.vht_claims_lakehouse_project.project_id
}

output "project_arn" {
  description = "The ARN of the SageMaker project"
  value       = module.vht_claims_lakehouse_project.project_arn
}

output "project_name" {
  description = "The name of the SageMaker project"
  value       = var.PROJECT_NAME
}

output "project_role_arn" {
  description = "The IAM role ARN for the project"
  value       = module.vht_claims_lakehouse_project.project_role_arn
}

output "project_s3_bucket" {
  description = "The S3 bucket for the project"
  value       = module.vht_claims_lakehouse_project.project_s3_bucket
}
