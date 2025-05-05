// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_ssoadmin_instances" "identity_center" {}

locals {
  # Parse the JSON string from SSM Parameter Store
  json_data = jsondecode(local.SMUS_DOMAIN_USER_MAPPINGS)

  # Extract user IDs using nested for expressions
  user_emails = flatten([
    for domain, groups in local.json_data : [
      for group, users in groups : users
    ]
  ])

  # Extract all unique emails from Domain Owner group across all domains
  domain_owner_emails = flatten([
    for domain, groups in local.json_data : groups["Domain Owner"]
  ])
}

# Data source to look up user IDs by email
data "aws_identitystore_user" "users" {
  for_each = toset(nonsensitive(local.user_emails))

  identity_store_id = data.aws_ssoadmin_instances.identity_center.identity_store_ids[0]
  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}

# Data source to look up domain owners by email
data "aws_identitystore_user" "domain_owners" {
  for_each = toset(nonsensitive(local.domain_owner_emails))

  identity_store_id = data.aws_ssoadmin_instances.identity_center.identity_store_ids[0]
  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}

resource "awscc_datazone_user_profile" "user" {
  for_each = toset(nonsensitive(local.user_emails))

  depends_on = [ null_resource.create_smus_domain ]
  domain_identifier = local.domain_id
  user_identifier   = data.aws_identitystore_user.users[each.key].user_id
  user_type = "SSO_USER"
  status = "ASSIGNED"
}

# Add 10 second delay before triggering "null_resource.add_root_owners"
resource "time_sleep" "wait_10_seconds" {
  depends_on = [ awscc_datazone_user_profile.user ]
  create_duration = "10s"
}

resource "null_resource" "add_root_owners" {
  depends_on = [ time_sleep.wait_10_seconds ]
  for_each = toset(nonsensitive(local.domain_owner_emails))

  triggers = {
    domain_id = local.domain_id
    user_id   = data.aws_identitystore_user.domain_owners[each.key].user_id
  }

  provisioner "local-exec" {
    command = <<-EOF
      aws datazone add-entity-owner \
        --domain-identifier ${local.domain_id} \
        --entity-type DOMAIN_UNIT \
        --entity-identifier ${local.root_domain_unit_id} \
        --owner '{"user": {"userIdentifier": "${data.aws_identitystore_user.domain_owners[each.key].user_id}"}}'
    EOF
  }
}

