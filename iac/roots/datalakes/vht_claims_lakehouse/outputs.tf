// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "database_name" {
  description = "Glue database name"
  value       = aws_glue_catalog_database.vht_claims_lakehouse_database.name
}

output "bucket_name" {
  description = "S3 bucket name for data lake storage"
  value       = module.vht_claims_lakehouse_bucket.bucket_id
}

output "bucket_arn" {
  description = "S3 bucket ARN for data lake storage"
  value       = module.vht_claims_lakehouse_bucket.bucket_arn
}

output "kms_key_arn" {
  description = "KMS key ARN for encryption"
  value       = module.vht_claims_lakehouse_kms.key_arn
}

output "kms_key_id" {
  description = "KMS key ID for encryption"
  value       = module.vht_claims_lakehouse_kms.key_id
}

output "table_names" {
  description = "List of created Glue table names"
  value       = [for table in aws_glue_catalog_table.healthcare_tables : table.name]
}

output "table_metadata" {
  description = "Table metadata and schemas"
  value       = var.TABLE_SCHEMAS
}