locals {
  alarm_arns = [
    module.step_1_lambda_monitoring.lambda_invocation_errors_cloudwatch_alarm_arn,
    module.step_1_lambda_monitoring.lambda_throttles_cloudwatch_alarm_arn,
    module.step_1_lambda_monitoring.lambda_iterator_age_cloudwatch_alarm_arn,
    module.step_2_lambda_monitoring.lambda_invocation_errors_cloudwatch_alarm_arn,
    module.step_2_lambda_monitoring.lambda_throttles_cloudwatch_alarm_arn,
    module.step_2_lambda_monitoring.lambda_iterator_age_cloudwatch_alarm_arn,
    module.step_3_lambda_monitoring.lambda_invocation_errors_cloudwatch_alarm_arn,
    module.step_3_lambda_monitoring.lambda_throttles_cloudwatch_alarm_arn,
    module.step_3_lambda_monitoring.lambda_iterator_age_cloudwatch_alarm_arn,
    module.step_4_lambda_monitoring.lambda_invocation_errors_cloudwatch_alarm_arn,
    module.step_4_lambda_monitoring.lambda_throttles_cloudwatch_alarm_arn,
    module.step_4_lambda_monitoring.lambda_iterator_age_cloudwatch_alarm_arn,
    module.cleanup_snapshots_lambda_monitoring.lambda_invocation_errors_cloudwatch_alarm_arn,
    module.cleanup_snapshots_lambda_monitoring.lambda_throttles_cloudwatch_alarm_arn,
    module.cleanup_snapshots_lambda_monitoring.lambda_iterator_age_cloudwatch_alarm_arn
  ]
}

resource "aws_sns_topic" "source_region_topic" {
  provider = aws.source
  name     = local.setup_name
}

data "aws_iam_policy_document" "source_retion_sns_policy" {
  provider = aws.source

  statement {
    sid       = "Allow_Publish_Alarms"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.source_region_topic.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = local.alarm_arns
    }
  }
}

resource "aws_sns_topic_policy" "source_region_topic" {
  provider = aws.source
  arn      = aws_sns_topic.source_region_topic.arn
  policy   = data.aws_iam_policy_document.source_retion_sns_policy.json
}

resource "aws_sns_topic" "target_region_topic" {
  provider = aws.intermediate
  name     = local.setup_name
}

data "aws_iam_policy_document" "target_retion_sns_policy" {
  provider = aws.intermediate

  statement {
    sid       = "Allow_Publish_Alarms"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.target_region_topic.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = local.alarm_arns
    }
  }
}

resource "aws_sns_topic_policy" "target_region_topic" {
  provider = aws.intermediate
  arn      = aws_sns_topic.target_region_topic.arn
  policy   = data.aws_iam_policy_document.target_retion_sns_policy.json
}

module "step_1_lambda_monitoring" {
  source                                     = "github.com/skyscrapers/terraform-cloudwatch//lambda_function?ref=2.0.1"
  lambda_function                            = aws_lambda_function.step_1.function_name
  sns_topic_arn                              = aws_sns_topic.source_region_topic.arn
  lambda_invocation_error_threshold          = 2
  lambda_invocation_error_period             = var.lambda_monitoring_metric_period
  lambda_invocation_error_evaluation_periods = 1

  providers = {
    aws = aws.source
  }
}

module "step_2_lambda_monitoring" {
  source                                     = "github.com/skyscrapers/terraform-cloudwatch//lambda_function?ref=2.0.1"
  lambda_function                            = aws_lambda_function.step_2.function_name
  sns_topic_arn                              = aws_sns_topic.source_region_topic.arn
  lambda_invocation_error_threshold          = 2
  lambda_invocation_error_period             = var.lambda_monitoring_metric_period
  lambda_invocation_error_evaluation_periods = 1

  providers = {
    aws = aws.source
  }
}

module "step_3_lambda_monitoring" {
  source                                     = "github.com/skyscrapers/terraform-cloudwatch//lambda_function?ref=2.0.1"
  lambda_function                            = aws_lambda_function.step_3.function_name
  sns_topic_arn                              = aws_sns_topic.target_region_topic.arn
  lambda_invocation_error_threshold          = 2
  lambda_invocation_error_period             = var.lambda_monitoring_metric_period
  lambda_invocation_error_evaluation_periods = 1

  providers = {
    aws = aws.intermediate
  }
}

module "step_4_lambda_monitoring" {
  source                                     = "github.com/skyscrapers/terraform-cloudwatch//lambda_function?ref=2.0.1"
  lambda_function                            = aws_lambda_function.step_4.function_name
  sns_topic_arn                              = aws_sns_topic.target_region_topic.arn
  lambda_invocation_error_threshold          = 2
  lambda_invocation_error_period             = var.lambda_monitoring_metric_period
  lambda_invocation_error_evaluation_periods = 1

  providers = {
    aws = aws.target
  }
}

module "cleanup_snapshots_lambda_monitoring" {
  source                                     = "github.com/skyscrapers/terraform-cloudwatch//lambda_function?ref=2.0.1"
  lambda_function                            = aws_lambda_function.cleanup_snapshots.function_name
  sns_topic_arn                              = aws_sns_topic.target_region_topic.arn
  lambda_invocation_error_threshold          = 2
  lambda_invocation_error_period             = var.lambda_monitoring_metric_period
  lambda_invocation_error_evaluation_periods = 1

  providers = {
    aws = aws.target
  }
}
