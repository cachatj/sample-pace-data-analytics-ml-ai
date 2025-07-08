// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "APP" {
  description = "Application name"
  type        = string
}

variable "ENV" {
  description = "Environment name"
  type        = string
}

variable "AWS_PRIMARY_REGION" {
  description = "Primary AWS region"
  type        = string
}

variable "AWS_SECONDARY_REGION" {
  description = "Secondary AWS region"
  type        = string
}

variable "PROJECT_NAME" {
  description = "DataZone project name"
  type        = string
  default     = "vht-analytics-consumer"
}

variable "PROJECT_DESCRIPTION" {
  description = "DataZone project description"
  type        = string
  default     = "Cross-project analytics and API endpoints for VHT-APP account access"
}

variable "PROJECT_GLOSSARY" {
  description = "Glossary terms for the project"
  type        = list(string)
  default     = ["healthcare", "analytics", "api", "cross-account", "consumer"]
}

variable "PROFILE_NAME" {
  description = "DataZone profile name"
  type        = string
  default     = "vht_analytics_consumer_profile"
}

variable "PROFILE_DESCRIPTION" {
  description = "DataZone profile description"
  type        = string
  default     = "vht-analytics-consumer project profile"
}

variable "ENV_NAME" {
  description = "DataZone environment name"
  type        = string
  default     = "vht_analytics_consumer_env"
}
