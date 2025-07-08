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
  "patient_demographics": {
    "description": "Patient demographic information for propensity modeling",
    "columns": [
      {
        "name": "patient_id",
        "type": "string"
      },
      {
        "name": "age_group",
        "type": "string"
      },
      {
        "name": "gender",
        "type": "string"
      },
      {
        "name": "location",
        "type": "string"
      },
      {
        "name": "insurance_type",
        "type": "string"
      }
    ]
  },
  "payment_history": {
    "description": "Historical payment patterns",
    "columns": [
      {
        "name": "payment_id",
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
        "name": "payment_amount",
        "type": "double"
      },
      {
        "name": "payment_date",
        "type": "timestamp"
      }
    ]
  },
  "propensity_scores": {
    "description": "Generated propensity scores",
    "columns": [
      {
        "name": "score_id",
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
        "name": "propensity_score",
        "type": "double"
      },
      {
        "name": "confidence_level",
        "type": "double"
      }
    ]
  }
}
}
