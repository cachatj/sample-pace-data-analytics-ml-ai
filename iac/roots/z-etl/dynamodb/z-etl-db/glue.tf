data "aws_iam_role" "glue_role" {

  name = var.GLUE_ROLE_NAME
}

data "aws_iam_policy_document" "catalog_resource_policy_doc" {
  statement {
    actions = [
      "glue:CreateInboundIntegration"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = [
      aws_glue_catalog_database.zetl_ddb_database.arn
    ]
  }
  statement {
    actions = [
      "glue:AuthorizeInboundIntegration"
    ]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    resources = [
      aws_glue_catalog_database.zetl_ddb_database.arn
    ]
  }
}

resource "aws_glue_resource_policy" "catalog_resource_policy" {
  policy = data.aws_iam_policy_document.catalog_resource_policy_doc.json
}

resource "aws_glue_catalog_database" "zetl_ddb_database" {

  name = "${var.APP}_${var.ENV}_equity_orders_zetl_ddb"
  location_uri = "s3://${module.equity_orders_zetl_ddb_bucket.primary_bucket_name}/"
  tags = {
    Application = var.APP
    Environment = var.ENV
    Usage       = "zetl-ddb"
  }
}

resource "aws_lakeformation_resource" "ddb_zetl_s3_location" {

  arn       = module.equity_orders_zetl_ddb_bucket.primary_bucket_arn
  role_arn  = aws_iam_role.aws_iam_glue_role.arn

  use_service_linked_role     = false
  hybrid_access_enabled       = false
}

resource "aws_lakeformation_permissions" "zetl_ddb_database_permission" {

  principal   = aws_iam_role.aws_iam_glue_role.arn
  permissions = ["CREATE_TABLE", "DESCRIBE", "ALTER", "DROP"]

  database {
    name = aws_glue_catalog_database.zetl_ddb_database.name
  }

  depends_on = [aws_glue_catalog_database.zetl_ddb_database]
}

resource "aws_lakeformation_permissions" "target_role_permission" {

  principal   = aws_iam_role.aws_iam_glue_role.arn
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location {
    arn = aws_lakeformation_resource.ddb_zetl_s3_location.arn
  }
}