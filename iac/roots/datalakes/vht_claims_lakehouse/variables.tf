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
  default     = "vht-claims-data-daily-feed"
}

variable "TABLE_SCHEMAS" {
  description = "Schema definitions for tables"
  type        = any
  default     = {
  "claims_837_iceberg": {
    "description": "837 Claims data with dynamic schema evolution - Professional and Institutional Claims",
    "partitions": [
      "client_id",
      "year",
      "month"
    ],
    "table_type": "ICEBERG",
    "storage_format": "PARQUET",
    "compression": "SNAPPY",
    "columns": [
      {
        "name": "source",
        "type": "string",
        "comment": "Source system identifier"
      },
      {
        "name": "Claim_id",
        "type": "string",
        "comment": "Unique claim identifier"
      },
      {
        "name": "claim_date",
        "type": "timestamp",
        "comment": "Date claim was submitted"
      },
      {
        "name": "service_date_from",
        "type": "timestamp",
        "comment": "Service start date"
      },
      {
        "name": "service_date_to",
        "type": "timestamp",
        "comment": "Service end date"
      },
      {
        "name": "diagnosis_code",
        "type": "string",
        "comment": "Primary diagnosis code (ICD-10)"
      },
      {
        "name": "line_id",
        "type": "double",
        "comment": "Service line identifier"
      },
      {
        "name": "procedure_code",
        "type": "string",
        "comment": "CPT/HCPCS procedure code"
      },
      {
        "name": "modifiers",
        "type": "string",
        "comment": "Procedure code modifiers"
      },
      {
        "name": "line_charge_amount",
        "type": "double",
        "comment": "Charged amount for service line"
      },
      {
        "name": "units",
        "type": "double",
        "comment": "Units of service"
      },
      {
        "name": "authorization_info",
        "type": "string",
        "comment": "Prior authorization details"
      },
      {
        "name": "service_facility_location",
        "type": "string",
        "comment": "Service facility information"
      },
      {
        "name": "place_of_service",
        "type": "double",
        "comment": "Place of service code"
      },
      {
        "name": "patient_first_name",
        "type": "string",
        "comment": "Patient first name"
      },
      {
        "name": "patient_last_name",
        "type": "string",
        "comment": "Patient last name"
      },
      {
        "name": "patient_dob",
        "type": "string",
        "comment": "Patient date of birth"
      },
      {
        "name": "patient_gender",
        "type": "string",
        "comment": "Patient gender"
      },
      {
        "name": "patient_zipcode",
        "type": "string",
        "comment": "Patient ZIP code"
      },
      {
        "name": "subscriber_id",
        "type": "string",
        "comment": "Insurance subscriber ID"
      },
      {
        "name": "subscriber_other_zipcode",
        "type": "string",
        "comment": "Subscriber ZIP code"
      },
      {
        "name": "subscriber_other_identification_code",
        "type": "string",
        "comment": "Additional subscriber ID"
      },
      {
        "name": "payer_name",
        "type": "string",
        "comment": "Insurance payer name"
      },
      {
        "name": "payer_id",
        "type": "string",
        "comment": "Insurance payer identifier"
      },
      {
        "name": "provider_name",
        "type": "string",
        "comment": "Rendering provider name"
      },
      {
        "name": "provider_id",
        "type": "string",
        "comment": "Provider NPI"
      },
      {
        "name": "provider_taxonomy_code",
        "type": "string",
        "comment": "Provider specialty taxonomy"
      },
      {
        "name": "Attending_Provider_Taxonomy_Code",
        "type": "string",
        "comment": "Attending provider taxonomy"
      },
      {
        "name": "Submitter_Name",
        "type": "string",
        "comment": "Claim submitter name"
      },
      {
        "name": "Submitter_Identifier",
        "type": "string",
        "comment": "Claim submitter ID"
      },
      {
        "name": "Receiver_Name",
        "type": "string",
        "comment": "Claim receiver name"
      },
      {
        "name": "Receiver_Identifier",
        "type": "string",
        "comment": "Claim receiver ID"
      },
      {
        "name": "client_id",
        "type": "string",
        "comment": "Client identifier (trs, haysmed, idg)"
      },
      {
        "name": "file_date",
        "type": "date",
        "comment": "Date of file processing"
      },
      {
        "name": "ingestion_timestamp",
        "type": "timestamp",
        "comment": "Data ingestion timestamp"
      },
      {
        "name": "year",
        "type": "string",
        "comment": "Partition year"
      },
      {
        "name": "month",
        "type": "string",
        "comment": "Partition month"
      }
    ]
  },
  "payments_835_iceberg": {
    "description": "835 Payment remittance data with dynamic schema evolution - Electronic Remittance Advice",
    "partitions": [
      "client_id",
      "year",
      "month"
    ],
    "table_type": "ICEBERG",
    "storage_format": "PARQUET",
    "compression": "SNAPPY",
    "columns": [
      {
        "name": "source",
        "type": "string",
        "comment": "Source system identifier"
      },
      {
        "name": "claim_id",
        "type": "string",
        "comment": "Related claim identifier"
      },
      {
        "name": "adjudicated_date",
        "type": "string",
        "comment": "Date claim was adjudicated"
      },
      {
        "name": "service_line_number",
        "type": "string",
        "comment": "Service line reference"
      },
      {
        "name": "patient_first_name",
        "type": "string",
        "comment": "Patient first name"
      },
      {
        "name": "patient_last_name",
        "type": "string",
        "comment": "Patient last name"
      },
      {
        "name": "procedure_code",
        "type": "string",
        "comment": "CPT/HCPCS procedure code"
      },
      {
        "name": "modifiers",
        "type": "string",
        "comment": "Procedure code modifiers"
      },
      {
        "name": "Units",
        "type": "double",
        "comment": "Units of service"
      },
      {
        "name": "paid_amount",
        "type": "double",
        "comment": "Amount paid by payer"
      },
      {
        "name": "billed_amount",
        "type": "double",
        "comment": "Amount originally billed"
      },
      {
        "name": "allowed_amount",
        "type": "double",
        "comment": "Payer allowed amount"
      },
      {
        "name": "Adjustment_Amount",
        "type": "double",
        "comment": "Total adjustments"
      },
      {
        "name": "Adjustment_Code",
        "type": "string",
        "comment": "Reason for adjustment"
      },
      {
        "name": "PAYER_NAME",
        "type": "string",
        "comment": "Insurance payer name"
      },
      {
        "name": "was_forwarded",
        "type": "string",
        "comment": "Secondary payer indicator"
      },
      {
        "name": "PAYMENT_DATE",
        "type": "string",
        "comment": "Date payment was issued"
      },
      {
        "name": "claim_adjustment_reason_code",
        "type": "string",
        "comment": "CARC codes"
      },
      {
        "name": "remark_codes",
        "type": "string",
        "comment": "Remittance remark codes"
      },
      {
        "name": "payer_claim_control_number",
        "type": "string",
        "comment": "Payer internal claim ID"
      },
      {
        "name": "claim_status_code",
        "type": "string",
        "comment": "Claim processing status"
      },
      {
        "name": "client_id",
        "type": "string",
        "comment": "Client identifier (trs, haysmed, idg)"
      },
      {
        "name": "payment_id",
        "type": "string",
        "comment": "Payment batch identifier"
      },
      {
        "name": "file_date",
        "type": "date",
        "comment": "Date of file processing"
      },
      {
        "name": "ingestion_timestamp",
        "type": "timestamp",
        "comment": "Data ingestion timestamp"
      },
      {
        "name": "year",
        "type": "string",
        "comment": "Partition year"
      },
      {
        "name": "month",
        "type": "string",
        "comment": "Partition month"
      }
    ]
  },
  "data_quality_metrics": {
    "description": "Data quality monitoring and validation results for healthcare claims processing",
    "partitions": [
      "validation_date"
    ],
    "table_type": "ICEBERG",
    "storage_format": "PARQUET",
    "columns": [
      {
        "name": "file_path",
        "type": "string",
        "comment": "Source file path"
      },
      {
        "name": "client_id",
        "type": "string",
        "comment": "Client identifier"
      },
      {
        "name": "claim_type",
        "type": "string",
        "comment": "Type of claim (837, 835)"
      },
      {
        "name": "record_count",
        "type": "bigint",
        "comment": "Number of records processed"
      },
      {
        "name": "expected_minimum",
        "type": "bigint",
        "comment": "Expected minimum record count"
      },
      {
        "name": "validation_status",
        "type": "string",
        "comment": "Overall validation result"
      },
      {
        "name": "validation_timestamp",
        "type": "timestamp",
        "comment": "When validation was performed"
      },
      {
        "name": "validation_date",
        "type": "date",
        "comment": "Date partition"
      },
      {
        "name": "errors",
        "type": "array<string>",
        "comment": "List of validation errors"
      },
      {
        "name": "warnings",
        "type": "array<string>",
        "comment": "List of validation warnings"
      },
      {
        "name": "completeness_score",
        "type": "double",
        "comment": "Data completeness percentage"
      },
      {
        "name": "accuracy_score",
        "type": "double",
        "comment": "Data accuracy percentage"
      },
      {
        "name": "consistency_score",
        "type": "double",
        "comment": "Data consistency percentage"
      },
      {
        "name": "timeliness_score",
        "type": "double",
        "comment": "Data timeliness percentage"
      }
    ]
  },
  "claims_linkage": {
    "description": "Linkage table connecting 837 claims with 835 payments for revenue cycle analytics",
    "partitions": [
      "client_id",
      "year",
      "month"
    ],
    "table_type": "ICEBERG",
    "storage_format": "PARQUET",
    "columns": [
      {
        "name": "linkage_id",
        "type": "string",
        "comment": "Unique linkage identifier"
      },
      {
        "name": "claim_id",
        "type": "string",
        "comment": "837 claim identifier"
      },
      {
        "name": "payment_id",
        "type": "string",
        "comment": "835 payment identifier"
      },
      {
        "name": "client_id",
        "type": "string",
        "comment": "Client identifier"
      },
      {
        "name": "payer_id",
        "type": "string",
        "comment": "Payer identifier"
      },
      {
        "name": "total_billed",
        "type": "double",
        "comment": "Total amount billed"
      },
      {
        "name": "total_paid",
        "type": "double",
        "comment": "Total amount paid"
      },
      {
        "name": "total_adjustments",
        "type": "double",
        "comment": "Total adjustments"
      },
      {
        "name": "days_to_payment",
        "type": "int",
        "comment": "Days from claim to payment"
      },
      {
        "name": "payment_ratio",
        "type": "double",
        "comment": "Paid/Billed ratio"
      },
      {
        "name": "denial_amount",
        "type": "double",
        "comment": "Amount denied"
      },
      {
        "name": "appeal_potential",
        "type": "string",
        "comment": "Appeal potential indicator"
      },
      {
        "name": "created_timestamp",
        "type": "timestamp",
        "comment": "Record creation time"
      },
      {
        "name": "year",
        "type": "string",
        "comment": "Partition year"
      },
      {
        "name": "month",
        "type": "string",
        "comment": "Partition month"
      }
    ]
  }
}
}
