data "aws_iam_policy_document" "glue_assume_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "intergration_lambda_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:CreateIntegration",
          "glue:DeleteIntegration",
          "ssm:PutParameter",
          "ssm:DeleteParameter",
          "ssm:GetParameter",
          "iam:PassRole",
          "kms:*"
        ]
        Resource = [
          "arn:aws:glue:${var.AWS_PRIMARY_REGION}:${data.aws_caller_identity.current.account_id}:connection/*", 
          "arn:aws:glue:${var.AWS_PRIMARY_REGION}:${data.aws_caller_identity.current.account_id}:database/*", 
          "arn:aws:glue:${var.AWS_PRIMARY_REGION}:${data.aws_caller_identity.current.account_id}:catalog/*",
          "arn:aws:glue:${var.AWS_PRIMARY_REGION}:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:${var.AWS_PRIMARY_REGION}:${data.aws_caller_identity.current.account_id}:integration/*",
          "arn:aws:ssm:${var.AWS_PRIMARY_REGION}:${data.aws_caller_identity.current.account_id}:parameter/*",
          aws_iam_role.aws_iam_glue_role.arn,
          "${data.aws_kms_key.glue_primary_key.arn}", 
          "${data.aws_kms_key.s3_primary_key.arn}"
          ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:CreateIntegrationResourceProperty",
          "glue:CreateIntegrationTableProperties",
          "glue:CreateInboundIntegration"
        ]
        Resource = [
          "*"
          ]
      },
    ]
  })
  
}

resource "aws_iam_role" "aws_iam_glue_role" {
  name = "${var.APP}-${var.ENV}-zetl-ddb-target-role"
  tags = {
    Application = var.APP
    Environment = var.ENV
    Usage       = "glue"
  }
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "glue_policy" {
  name = "${var.APP}-${var.ENV}-zetl-ddb-target-role-policy"
  role = aws_iam_role.aws_iam_glue_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:*"
        ]
        Resource = ["${module.equity_orders_zetl_ddb_bucket.primary_bucket_arn}/*", "${module.equity_orders_zetl_ddb_bucket.secondary_bucket_arn}/*", "${module.equity_orders_zetl_ddb_bucket.primary_bucket_arn}", "${module.equity_orders_zetl_ddb_bucket.secondary_bucket_arn}"]

      },
      {
        Effect   = "Allow"
        Action   = [
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartitions",
          "glue:GetUserDefinedFunctions",
          "glue:*"
        ]
        Resource = ["arn:aws:glue:${var.AWS_PRIMARY_REGION}:${data.aws_caller_identity.current.account_id}:catalog", "arn:aws:glue:${var.AWS_PRIMARY_REGION}:${data.aws_caller_identity.current.account_id}:database/*", "arn:aws:glue:${var.AWS_PRIMARY_REGION}:${data.aws_caller_identity.current.account_id}:table/*"]
      },
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = ["*"]
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "AWS/Glue/ZeroETL"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:Encrypt",
          "kms:DescribeKey"
        ]
        Resource = ["${data.aws_kms_key.glue_primary_key.arn}", "${data.aws_kms_key.s3_primary_key.arn}"]
      }
    ]
  })
}
