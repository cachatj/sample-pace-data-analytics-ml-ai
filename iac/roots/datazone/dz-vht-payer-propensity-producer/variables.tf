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
  default     = "vht-payer-propensity-producer"
}

variable "PROJECT_DESCRIPTION" {
  description = "DataZone project description"
  type        = string
  default     = "ML pipeline for payer propensity modeling with feature engineering and inference endpoints"
}

variable "PROJECT_GLOSSARY" {
  description = "Glossary terms for the project"
  type        = list(string)
  default     = ["healthcare", "payer", "propensity", "machine-learning", "claims", "revenue-cycle"]
}

variable "PROFILE_NAME" {
  description = "DataZone profile name"
  type        = string
  default     = "vht_payer_propensity_producer_profile"
}

variable "PROFILE_DESCRIPTION" {
  description = "DataZone profile description"
  type        = string
  default     = "vht-payer-propensity-producer project profile"
}

variable "ENV_NAME" {
  description = "DataZone environment name"
  type        = string
  default     = "vht_payer_propensity_producer_env"
}
