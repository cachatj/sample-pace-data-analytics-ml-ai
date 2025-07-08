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
  default     = "vht-rag-chat-producer"
}

variable "PROJECT_DESCRIPTION" {
  description = "Description of the SageMaker project"
  type        = string
  default     = "Multiple RAG applications and knowledge-based chat solutions"
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
  default     = "vht-ds-analytic-data"
}

variable "ENVIRONMENT_CONFIGS" {
  description = "Environment configurations for blueprints"
  type        = any
  default     = [
  {
    "name": "RAG Applications Environment",
    "description": "Multiple RAG chatbots with client-specific knowledge bases",
    "blueprint": "bedrock-rag",
    "deployment_order": 1,
    "parameters": {
      "knowledge_bases": [
        {
          "name": "client-sop-kb",
          "description": "Client standard operating procedures and coding policies",
          "data_source": "s3://vht-ds-analytic-data/client-documents/",
          "chunk_size": 1000,
          "chunk_overlap": 200
        },
        {
          "name": "revamp-support-kb",
          "description": "RevAmp tool user guides and training materials",
          "data_source": "s3://vht-ds-analytic-data/revamp-documentation/",
          "chunk_size": 1000,
          "chunk_overlap": 200
        }
      ],
      "embedding_model": "amazon.titan-embed-text-v1",
      "chat_model": "anthropic.claude-3-sonnet-20240229-v1:0"
    }
  }
]
}

variable "TABLE_SCHEMAS" {
  description = "Schema definitions for project tables"
  type        = any
  default     = {
  "chat_interactions": {
    "description": "Chat interaction logs and metrics",
    "columns": [
      {
        "name": "session_id",
        "type": "string"
      },
      {
        "name": "user_query",
        "type": "string"
      },
      {
        "name": "bot_response",
        "type": "string"
      },
      {
        "name": "knowledge_base_used",
        "type": "string"
      },
      {
        "name": "confidence_score",
        "type": "double"
      },
      {
        "name": "interaction_timestamp",
        "type": "timestamp"
      }
    ]
  }
}
}
