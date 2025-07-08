// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Data sources for existing DAIVI infrastructure
data "aws_ssm_parameter" "smus_domain_id" {
  name = "/${var.APP}/${var.ENV}/smus_domain_id"
}

data "aws_ssm_parameter" "smus_profile" {
  name = var.PROJECT_TYPE == "producer" ? "/${var.APP}/${var.ENV}/project_profile_1" : "/${var.APP}/${var.ENV}/project_profile_3"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  profile_id = split(":", data.aws_ssm_parameter.smus_profile.value)[0]
}

# Create SageMaker project using existing DAIVI template module
# Following IaC principle: Components should primarily compose reusable modules
module "vht_analytics_consumer_project" {
  source = "../../templates/modules/sagemaker-project"
  
  # Standard DAIVI variables
  APP                = var.APP
  ENV                = var.ENV
  AWS_PRIMARY_REGION = var.AWS_PRIMARY_REGION
  
  # Project configuration
  PROJECT_NAME        = var.PROJECT_NAME
  PROJECT_DESCRIPTION = var.PROJECT_DESCRIPTION
  PROJECT_TYPE        = var.PROJECT_TYPE
  
  # SageMaker configuration
  SMUS_DOMAIN_ID      = data.aws_ssm_parameter.smus_domain_id.value
  SMUS_PROFILE_ID     = local.profile_id
  
  # Additional project-specific parameters
  GLUE_DATABASE       = "${var.APP}_${var.ENV}_vht_analytics_consumer_lakehouse"
  WORKGROUP_NAME      = "${var.APP}-${var.ENV}-workgroup"
  
  # Tags
  tags = {
    Application = var.APP
    Environment = var.ENV
    ProjectType = var.PROJECT_TYPE
    ProjectName = var.PROJECT_NAME
    ManagedBy   = "DAIVI-Custom-Project-Generator"
    UseCase     = "Healthcare-Revenue-Cycle"
  }
}

# Store project information in SSM for cross-project references
# Using local resource for parameter storage only
resource "aws_ssm_parameter" "vht_analytics_consumer_project_id" {
  name  = "/${var.APP}/${var.ENV}/projects/vht-analytics-consumer/project_id"
  type  = "String"
  value = module.vht_analytics_consumer_project.project_id
  
  tags = {
    Application = var.APP
    Environment = var.ENV
    ProjectName = var.PROJECT_NAME
  }
}

resource "aws_ssm_parameter" "vht_analytics_consumer_project_arn" {
  name  = "/${var.APP}/${var.ENV}/projects/vht-analytics-consumer/project_arn"
  type  = "String"
  value = module.vht_analytics_consumer_project.project_arn
  
  tags = {
    Application = var.APP
    Environment = var.ENV
    ProjectName = var.PROJECT_NAME
  }
}
