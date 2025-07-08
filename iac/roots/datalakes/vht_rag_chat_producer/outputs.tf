// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "database_name" {
  description = "Glue database name"
  value       = module.vht_rag_chat_producer_datalake.database_name
}

output "s3_table_bucket" {
  description = "S3 Tables bucket for Iceberg"
  value       = module.vht_rag_chat_producer_datalake.s3_table_bucket
}

output "support_bucket" {
  description = "S3 bucket for support files"
  value       = module.vht_rag_chat_producer_datalake.support_bucket
}

output "table_metadata" {
  description = "Table metadata and schemas"
  value       = module.vht_rag_chat_producer_datalake.table_metadata
}
