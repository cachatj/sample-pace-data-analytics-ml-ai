// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Data sources for existing DAIVI infrastructure
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create DataLake using existing DAIVI template modules
# Following IaC principle: Components should primarily compose reusable modules
module "vht_claims_lakehouse_datalake" {
  source = "../../templates/modules/datalake-iceberg"
  
  APP                = var.APP
  ENV                = var.ENV
  AWS_PRIMARY_REGION = var.AWS_PRIMARY_REGION
  
  DATABASE_NAME      = "${var.APP}_${var.ENV}_vht_claims_lakehouse_lakehouse"
  SOURCE_BUCKET      = var.SOURCE_BUCKET
  TABLE_SCHEMAS      = var.TABLE_SCHEMAS
  
  # Healthcare-specific configuration
  ENABLE_ENCRYPTION  = true
  COMPLIANCE_MODE    = "HIPAA"
  DATA_CLASSIFICATION = "PHI"
  
  tags = {
    Application = var.APP
    Environment = var.ENV
    UseCase     = "Healthcare-Revenue-Cycle"
    DataType    = "Claims-and-Payments"
  }
}

# Store datalake information in SSM for cross-project references
resource "aws_ssm_parameter" "vht_claims_lakehouse_database_name" {
  name  = "/${var.APP}/${var.ENV}/datalakes/vht_claims_lakehouse/database_name"
  type  = "String"
  value = module.vht_claims_lakehouse_datalake.database_name
  
  tags = {
    Application = var.APP
    Environment = var.ENV
  }
}
