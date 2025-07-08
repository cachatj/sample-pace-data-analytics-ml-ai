// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Data sources for existing DAIVI infrastructure
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create KMS key for data lake encryption
module "vht_claims_lakehouse_kms" {
  source = "../../../templates/modules/kms"
  
  alias       = "${var.APP}-${var.ENV}-vht-claims-lakehouse"
  description = "KMS key for VHT Claims Lakehouse data encryption"
  roles       = []
  services    = ["s3.amazonaws.com", "glue.amazonaws.com"]
}

# Create S3 bucket for data lake storage
module "vht_claims_lakehouse_bucket" {
  source = "../../../templates/modules/bucket"
  
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }
  
  RESOURCE_PREFIX               = "${var.APP}-${var.ENV}-vht-claims-lakehouse"
  BUCKET_NAME_PRIMARY_REGION   = "primary"
  BUCKET_NAME_SECONDARY_REGION = "secondary"
  PRIMARY_CMK_ARN              = module.vht_claims_lakehouse_kms.key_arn
  SECONDARY_CMK_ARN            = module.vht_claims_lakehouse_kms.key_arn
  APP                          = var.APP
  ENV                          = var.ENV
  USAGE                        = "datalake"
}

# Create Glue database for metadata
resource "aws_glue_catalog_database" "vht_claims_lakehouse_database" {
  name        = "${var.APP}_${var.ENV}_vht_claims_lakehouse_lakehouse"
  description = "VHT Claims Lakehouse database for healthcare revenue cycle management"
  
  catalog_id = data.aws_caller_identity.current.account_id
  
  create_table_default_permission {
    permissions = ["ALL"]
    principal   = data.aws_caller_identity.current.arn
  }
}

# Create Glue tables based on TABLE_SCHEMAS
resource "aws_glue_catalog_table" "healthcare_tables" {
  for_each = var.TABLE_SCHEMAS
  
  name               = each.key
  database_name      = aws_glue_catalog_database.vht_claims_lakehouse_database.name
  description        = each.value.description
  table_type         = "EXTERNAL_TABLE"
  
  parameters = {
    "table_type"           = each.value.table_type
    "classification"       = lower(each.value.storage_format)
    "compressionType"      = lower(each.value.compression)
    "serialization.format" = "1"
  }

  storage_descriptor {
    location      = "s3://${module.vht_claims_lakehouse_bucket.bucket_id}/${each.key}/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
      }
    }
    
    dynamic "columns" {
      for_each = each.value.columns
      content {
        name    = columns.value.name
        type    = columns.value.type
        comment = columns.value.comment
      }
    }
  }
  
  dynamic "partition_keys" {
    for_each = each.value.partitions
    content {
      name = partition_keys.value
      type = "string"
    }
  }
}

# Store datalake information in SSM for cross-project references
resource "aws_ssm_parameter" "vht_claims_lakehouse_database_name" {
  name  = "/${var.APP}/${var.ENV}/datalakes/vht_claims_lakehouse/database_name"
  type  = "String"
  value = aws_glue_catalog_database.vht_claims_lakehouse_database.name
  
  tags = {
    Application = var.APP
    Environment = var.ENV
  }
}

resource "aws_ssm_parameter" "vht_claims_lakehouse_bucket_name" {
  name  = "/${var.APP}/${var.ENV}/datalakes/vht_claims_lakehouse/bucket_name"
  type  = "String"
  value = module.vht_claims_lakehouse_bucket.bucket_id
  
  tags = {
    Application = var.APP
    Environment = var.ENV
  }
}

resource "aws_ssm_parameter" "vht_claims_lakehouse_kms_key_arn" {
  name  = "/${var.APP}/${var.ENV}/datalakes/vht_claims_lakehouse/kms_key_arn"
  type  = "String"
  value = module.vht_claims_lakehouse_kms.key_arn
  
  tags = {
    Application = var.APP
    Environment = var.ENV
  }
}

# Store table schemas in SSM for reference by other components
resource "aws_ssm_parameter" "vht_claims_lakehouse_table_schemas" {
  name  = "/${var.APP}/${var.ENV}/datalakes/vht_claims_lakehouse/table_schemas"
  type  = "String"
  value = jsonencode(var.TABLE_SCHEMAS)
  
  tags = {
    Application = var.APP
    Environment = var.ENV
  }
}