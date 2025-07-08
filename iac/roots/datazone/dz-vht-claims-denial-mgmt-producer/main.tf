// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Data sources for existing DAIVI infrastructure
data "aws_ssm_parameter" "datazone_domain_id" {
  name = "/${var.APP}/${var.ENV}/datazone_domain_id"
}

data "aws_ssm_parameter" "datalake_blueprint_id" {
  name = "/${var.APP}/${var.ENV}/${data.aws_ssm_parameter.datazone_domain_id.value}/datalake_blueprint_id"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create DataZone project using existing DAIVI template module
# Following IaC principle: Components should primarily compose reusable modules
module "vht_claims_denial_mgmt_producer_datazone_project" {
  source = "../../templates/modules/datazone-project"
  
  APP                 = var.APP
  ENV                 = var.ENV
  AWS_PRIMARY_REGION  = var.AWS_PRIMARY_REGION
  
  PROJECT_NAME        = var.PROJECT_NAME
  PROJECT_DESCRIPTION = var.PROJECT_DESCRIPTION
  PROFILE_NAME        = var.PROFILE_NAME
  PROFILE_DESCRIPTION = var.PROFILE_DESCRIPTION
  ENV_NAME           = var.ENV_NAME
  PROJECT_GLOSSARY   = var.PROJECT_GLOSSARY
  
  DATAZONE_DOMAIN_ID  = data.aws_ssm_parameter.datazone_domain_id.value
  BLUEPRINT_ID        = data.aws_ssm_parameter.datalake_blueprint_id.value
  
  tags = {
    Application = var.APP
    Environment = var.ENV
    ProjectName = var.PROJECT_NAME
    UseCase     = "Healthcare-Revenue-Cycle"
  }
}
