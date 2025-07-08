// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

APP                             = "vhtds"
ENV                             = "dev"
AWS_PRIMARY_REGION              = "us-east-1"
AWS_SECONDARY_REGION            = "us-east-2"
SSM_KMS_KEY_ALIAS               = "vhtds-dev-systems-manager-secret-key"
DOMAIN_NAME                     = "Exchange"

PROJECT_PRODUCER_NAME           = "Producer"
PROJECT_PRODUCER_DESCRIPTION    = "Data Producer Project"

PRODUCER_PROFILE_NAME           = "producer_datalake_profile"
PRODUCER_PROFILE_DESCRIPTION    = "producer datalake profile"

PROJECT_GLOSSARY                = ["term1", "term2"]
PRODUCER_ENV_NAME                = "producer_env"

DATASOURCE_NAME = "glue_data"
DATASOURCE_TYPE = "GLUE"

GLUE_DATASOURCE_CONFIGURATION = {
    glue_run_configuration = {
        auto_import_data_quality_result = true
        relational_filter_configurations = [{
            database_name = "vhtds_dev_billing"
            filter_expression = [{
                expression = "*"
                type = "INCLUDE"
            }]
        }]
    }
}
