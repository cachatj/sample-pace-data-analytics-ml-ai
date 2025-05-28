// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_s3_object" "trading_data_generator_script" {

  bucket     = data.aws_s3_bucket.glue_scripts_bucket.id
  key        = "trading_data_generator.py"
  source     = "${path.module}/src/lambda/trading_data_generator.py"
  kms_key_id = data.aws_kms_key.s3_primary_key.arn
}

resource "aws_glue_job" "trading_data_generator_job" {

  name              = "${var.APP}-${var.ENV}-trading-data-generator"
  description       = "${var.APP}-${var.ENV}-trading-data-generator"
  role_arn          = data.aws_iam_role.glue_role.arn
  glue_version      = "5.0"
  worker_type       = "G.1X"
  number_of_workers = 10

  security_configuration = var.GLUE_SECURITY_CONFIGURATION

  command {
    script_location = "s3://${var.GLUE_SCRIPTS_BUCKET_NAME}/trading_data_generator.py"
  }

  default_arguments = {
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-job-insights"              = "true"
    "--enable-observability-metrics"     = "true"
    "--enable-spark-ui"                  = "true"
    "--job-language"                     = "python"
    "--TempDir"                          = var.GLUE_TEMP_BUCKET
    "--spark-event-logs-path"            = var.GLUE_SPARK_LOGS_BUCKET
    "--SNOWFLAKE_URL"                    = data.aws_ssm_parameter.snowflake_host.value
    "--SNOWFLAKE_DATABASE_NAME"          = data.aws_ssm_parameter.snowflake_database.value
    "--SNOWFLAKE_SCHEMA_NAME"            = data.aws_ssm_parameter.snowflake_schema.value
    "--SNOWFLAKE_WAREHOUSE_NAME"         = data.aws_ssm_parameter.snowflake_warehouse.value
    "--SNOWFLAKE_TABLE_NAME"             = var.SNOWFLAKE_TABLE_NAME
    "--SNOWFLAKE_SECRET_NAME"            = var.SNOWFLAKE_SECRET_NAME
  }
}
