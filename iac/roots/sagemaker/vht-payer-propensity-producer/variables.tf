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
  default     = "vht-payer-propensity-producer"
}

variable "PROJECT_DESCRIPTION" {
  description = "Description of the SageMaker project"
  type        = string
  default     = "ML pipeline for payer propensity modeling with feature engineering and inference endpoints"
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
    "name": "ML Pipeline Environment",
    "description": "SageMaker training, feature store, and inference endpoints",
    "blueprint": "sagemaker-ml-pipeline",
    "deployment_order": 1,
    "parameters": {
      "s3_raw_data_bucket": "vht-ds-raw-data",
      "s3_staged_data_bucket": "vht-ds-staged-data",
      "s3_analytic_data_bucket": "vht-ds-analytic-data",
      "feature_store_name": "payer-propensity-features",
      "model_registry_name": "payer-propensity-models",
      "training_instance_type": "ml.m5.2xlarge",
      "inference_instance_type": "ml.m5.xlarge",
      "max_runtime_seconds": 86400
    }
  },
  {
    "name": "Lakehouse Database",
    "description": "Iceberg tables for payer propensity data",
    "blueprint": "lakehouse-database",
    "deployment_order": 2,
    "parameters": {
      "database_name": "vht_payer_propensity",
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
