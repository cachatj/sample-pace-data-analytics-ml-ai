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
  default     = "vht-ds-analytic-data"
}

variable "TABLE_SCHEMAS" {
  description = "Schema definitions for tables"
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
