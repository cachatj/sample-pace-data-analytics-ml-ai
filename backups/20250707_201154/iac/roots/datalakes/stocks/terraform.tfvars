// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

APP                                = "vhtds"
ENV                                = "dev"
AWS_PRIMARY_REGION                 = "us-east-1"
AWS_SECONDARY_REGION               = "us-east-2"
SSM_KMS_KEY_ALIAS                  = "vhtds-dev-systems-manager-secret-key"
FLINK_S3_BUCKET                    = "vhtds-dev-flink-s3-bucket"
FLINK_S3_FILE_KEY                  = "flink.jar"
FLINK_APP_RUNTIME_ENV              = "FLINK-1_20"
FLINK_APP_PARALLELISM              = 1
FLINK_APP_ALLOW_NON_RESTORED_STATE = false
FLINK_APP_PARALLELISM_PER_KPU      = 1
FLINK_APP_AUTOSCALING_ENABLED      = false
FLINK_APP_MONITORING_LOG_LEVEL     = "INFO"
FLINK_APP_MONITORING_METRICS_LEVEL = "APPLICATION"
FLINK_APP_SNAPSHOTS_ENABLED        = true
FLINK_APP_START                    = true
CODE_CONTENT_TYPE                  = "ZIPFILE"
FLINK_APP_ENVIRONMENT_VARIABLES = {
  "SINK_TOPIC_NAME" : "intraday-sink-topic"
  "SOURCE_TOPIC_NAME" : "intraday-source-topic"
}
