// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "APP" {
  description = "Application name for resource naming and tagging"
  type        = string
}

variable "ENV" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "AWS_PRIMARY_REGION" {
  description = "Primary AWS region for deployment"
  type        = string
}

variable "AWS_SECONDARY_REGION" {
  description = "Secondary AWS region for cross-region resources"
  type        = string
}

variable "PROJECT_NAME" {
  description = "Name of the SageMaker project"
  type        = string
  default     = "vht-analytics-consumer"
}

variable "PROJECT_DESCRIPTION" {
  description = "Description of the SageMaker project"
  type        = string
  default     = "Cross-project analytics and API endpoints for VHT-APP account access"
}

variable "PROJECT_TYPE" {
  description = "Type of project (producer or consumer)"
  type        = string
  default     = "consumer"
  
  validation {
    condition     = contains(["producer", "consumer"], var.PROJECT_TYPE)
    error_message = "PROJECT_TYPE must be either 'producer' or 'consumer'."
  }
}

variable "SOURCE_BUCKET" {
  description = "Source S3 bucket for data"
  type        = string
  default     = "vht-ds-analytic-data"
}

variable "ENVIRONMENT_CONFIGS" {
  description = "Environment configurations for blueprints"
  type        = any
  default     = [
  {
    "name": "Cross-Account API Environment",
    "description": "API Gateway and Lambda functions for VHT-APP account access",
    "blueprint": "api-gateway-lambda",
    "deployment_order": 1,
    "parameters": {
      "api_gateway_name": "vht-analytics-api",
      "cross_account_role": "arn:aws:iam::254145955434:role/VHT-APP-DataAccess-Role",
      "endpoints": [
        "/propensity-score",
        "/claims-denial-prediction",
        "/chatbot-query"
      ],
      "throttle_rate_limit": 1000,
      "throttle_burst_limit": 2000
    }
  },
  {
    "name": "Unified Analytics Database",
    "description": "Consolidated analytics across all projects",
    "blueprint": "lakehouse-database",
    "deployment_order": 2,
    "parameters": {
      "database_name": "vht_unified_analytics",
      "federated_queries": true,
      "cross_project_access": true,
      "source_databases": [
        "vht_payer_propensity",
        "vht_claims_denial"
      ]
    }
  }
]
}

variable "TABLE_SCHEMAS" {
  description = "Schema definitions for project tables"
  type        = any
  default     = {
  "unified_analytics": {
    "description": "Cross-project analytics and metrics",
    "columns": [
      {
        "name": "analytics_id",
        "type": "string"
      },
      {
        "name": "project_source",
        "type": "string"
      },
      {
        "name": "metric_type",
        "type": "string"
      },
      {
        "name": "metric_value",
        "type": "double"
      },
      {
        "name": "calculation_timestamp",
        "type": "timestamp"
      }
    ]
  }
}
}
