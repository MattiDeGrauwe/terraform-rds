variable "name" {
  description = "Name of the setup"
  type        = string
}

variable "is_aurora_cluster" {
  description = "Whether we're backing up Aurora clusters instead of RDS instances"
  type        = bool
  default     = false
}

variable "rds_instance_ids" {
  description = "List of IDs of the RDS instances to back up. If using Aurora, provide the cluster IDs instead"
  type        = list(string)
}

variable "snapshot_schedule_expression" {
  description = "Snapshot frequency specified as a CloudWatch schedule expression. Can either be a `rate()` or `cron()` expression. Check the [AWS documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html#CronExpressions) on how to compose such expression."
  type        = string
  default     = "cron(0 */6 * * ? *)"
}

variable "retention_period" {
  description = "Snapshot retention period in days"
  type        = number
  default     = 14
}

variable "target_account_kms_key_id" {
  description = "KMS key to use to encrypt replicated RDS snapshots in the target AWS account"
  type        = string
}

variable "lambda_monitoring_metric_period" {
  description = "The metric period to use for the Lambdas CloudWatch alerts for monitoring. This should be equal or higher than the snapshoting period"
  type        = number
  default     = 21600 # 6 hours
}
