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
