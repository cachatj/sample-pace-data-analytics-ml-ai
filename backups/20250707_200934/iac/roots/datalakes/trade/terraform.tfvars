// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

APP                         = "vhtds"
ENV                         = "dev"
AWS_PRIMARY_REGION          = "us-east-1"
AWS_SECONDARY_REGION        = "us-east-2"
S3_PRIMARY_KMS_KEY_ALIAS    = "vhtds-dev-s3-secret-key"
S3_SECONDARY_KMS_KEY_ALIAS  = "vhtds-dev-s3-secret-key"
TRADE_TOPIC                 = "trade-topic"
GLUE_ROLE_NAME              = "vhtds-dev-glue-role"
TRADE_HIVE_BUCKET           = "s3://vhtds-dev-trade-hive-primary/"
TRADE_ICEBERG_BUCKET        = "s3://vhtds-dev-trade-iceberg-primary/"
GLUE_SPARK_LOGS_BUCKET      = "s3://vhtds-dev-glue-spark-logs-primary/"
GLUE_TEMP_BUCKET            = "s3://vhtds-dev-glue-temp-primary/"
GLUE_SCRIPTS_BUCKET_NAME    = "vhtds-dev-glue-scripts-primary"
GLUE_KMS_KEY_ALIAS          = "vhtds-dev-glue-secret-key"
CLOUDWATCH_KMS_KEY_ALIAS    = "vhtds-dev-cloudwatch-secret-key"
