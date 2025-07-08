// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

APP                   = "vhtds"
ENV                   = "dev"
AWS_PRIMARY_REGION    = "us-east-1"
AWS_SECONDARY_REGION  = "us-east-2"
S3_KMS_KEY_ALIAS      = "vhtds-dev-s3-secret-key"
SSM_KMS_KEY_ALIAS     = "vhtds-dev-systems-manager-secret-key"
DOMAIN_KMS_KEY_ALIAS  = "vhtds-dev-glue-secret-key"
CLOUDWATCH_KMS_KEY_ALIAS    = "vhtds-dev-cloudwatch-secret-key"

smus_domain_execution_role_name             = "smus-domain-execution-role"
smus_domain_service_role_name               = "smus-domain-service-role"
smus_domain_provisioning_role_name          = "smus-domain-provisioning-role"
smus_domain_bedrock_model_manage_role_name  = "smus_domain_bedrock_model_manage_role"
smus_domain_bedrock_model_consume_role_name = "smus-domain-bedrock-model-consume-role"
