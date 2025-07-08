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
  default     = "vht-claims-denial-mgmt-producer"
}

variable "PROJECT_DESCRIPTION" {
  description = "Description of the SageMaker project"
  type        = string
  default     = "Automated claims denial management using Bedrock Agents and predictive analytics"
}

variable "PROJECT_TYPE" {
  description = "Type of project (producer or consumer)"
  type        = string
  default     = "producer"
  
  validation {
    condition     = contains(["producer", "consumer"], var.PROJECT_TYPE)
    error_message = "PROJECT_TYPE must be either 'producer' or 'consumer'."
  }
}

variable "SOURCE_BUCKET" {
  description = "Source S3 bucket for data"
  type        = string
  default     = "vht-ds-raw-data"
}

variable "ENVIRONMENT_CONFIGS" {
  description = "Environment configurations for blueprints"
  type        = any
  default     = [
  {
    "name": "Bedrock Agents Environment",
    "description": "Amazon Bedrock agents for claims processing automation",
    "blueprint": "bedrock-agents",
    "deployment_order": 1,
    "parameters": {
      "knowledge_base_name": "claims-denial-kb",
      "agent_name": "claims-denial-agent",
      "foundation_model": "anthropic.claude-3-sonnet-20240229-v1:0",
      "vector_store": "opensearch-serverless",
      "embedding_model": "amazon.titan-embed-text-v1",
      "max_tokens": 4000
    }
  },
  {
    "name": "Claims Analytics Database",
    "description": "Iceberg tables for claims denial analytics",
    "blueprint": "lakehouse-database",
    "deployment_order": 2,
    "parameters": {
      "database_name": "vht_claims_denial",
      "table_format": "iceberg",
      "schema_evolution": "dynamic"
    }
  }
]
}

variable "TABLE_SCHEMAS" {
  description = "Schema definitions for project tables"
  type        = any
  default     = {
  "claims_history": {
    "description": "Historical claims data for denial analysis",
    "columns": [
      {
        "name": "claim_id",
        "type": "string"
      },
      {
        "name": "patient_id",
        "type": "string"
      },
      {
        "name": "payer_id",
        "type": "string"
      },
      {
        "name": "claim_amount",
        "type": "double"
      },
      {
        "name": "denial_status",
        "type": "string"
      }
    ]
  },
  "denial_reasons": {
    "description": "Categorized denial reasons and patterns",
    "columns": [
      {
        "name": "denial_id",
        "type": "string"
      },
      {
        "name": "claim_id",
        "type": "string"
      },
      {
        "name": "denial_code",
        "type": "string"
      },
      {
        "name": "denial_category",
        "type": "string"
      },
      {
        "name": "appeal_potential",
        "type": "string"
      }
    ]
  },
  "automated_responses": {
    "description": "AI-generated responses and recommendations",
    "columns": [
      {
        "name": "response_id",
        "type": "string"
      },
      {
        "name": "claim_id",
        "type": "string"
      },
      {
        "name": "recommended_action",
        "type": "string"
      },
      {
        "name": "confidence_score",
        "type": "double"
      },
      {
        "name": "generated_text",
        "type": "string"
      }
    ]
  }
}
}
