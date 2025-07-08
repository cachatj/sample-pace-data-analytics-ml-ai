// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "datazone_project_id" {
  description = "DataZone project ID"
  value       = module.vht_claims_denial_mgmt_producer_datazone_project.project_id
}

output "datazone_project_name" {
  description = "DataZone project name"
  value       = var.PROJECT_NAME
}

output "datazone_environment_id" {
  description = "DataZone environment ID"
  value       = module.vht_claims_denial_mgmt_producer_datazone_project.environment_id
}

output "datazone_profile_id" {
  description = "DataZone profile ID"
  value       = module.vht_claims_denial_mgmt_producer_datazone_project.profile_id
}
