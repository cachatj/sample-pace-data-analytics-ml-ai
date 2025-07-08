// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "APP" {
  type = string
}

variable "ENV" {
  type = string
}

variable "AWS_PRIMARY_REGION" {
  type = string
}

variable "AWS_SECONDARY_REGION" {
  type = string
}

variable "SOURCE_BUCKET" {
  description = "Source S3 bucket for data"
  type        = string
  default     = "vht-ds-raw-data"
}

variable "TABLE_SCHEMAS" {
  description = "Schema definitions for tables"
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
