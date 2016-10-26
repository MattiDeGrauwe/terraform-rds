# terraform-rds
Everything for RDS related terraform

## RDS
Creates a RDS instance, security_group, subnet_group and parameter_group

### Available variables:
* [`vpc_id`]: String(required): ID of the VPC where to deploy in
* [`security_groups`]: List(required) Security groups that are allowed to access the RDS
* [`subnets`]: List(required) Subnets to deploy the RDS in
* [`storage`]: String(optional) How many GBs of space does your database need?
* [`size`]: String(optional) RDS instance size
* [`storage_type`]: String(optional) Type of storage you want to use
* [`rds_password`]: String(optional) RDS root password
* [`rds_type`]: String(optional) RDS type: mysql or oracle (default: mysql)
* [`replicate_source_db`]: String(optional) RDS source to replicate from
* [`multi_az`]: bool(optional) Multi AZ for RDS master (default: true)
* [`backup_retention_period`]: int(optional) How long do you want to keep RDS backups (default: 14)
* [`apply_immediately`]: bool(optional) whether you want to Apply changes immediately (default: true)
* [`storage_encrypted`]: bool(optional) whether you want to Encrypt RDS storage (default: true)
* [`tag`]: String(optional) tag
* [`project`]: String(required) the name of the project this RDS belongs to
* [`environment`]: String(required) the name of the environment these subnets belong to (prod,stag,dev)


### Output:
 * [`rds_port`]: String: The port of the rds
 * [`rds_arn`]: String: The arn of the rds

### Example
```
module "rds" {
  source                  = "rds"
  vpc_id                  = "${module.vpc.vpc_id}"
  subnets                 = "${module.vpc.private_db_subnets}"
  project                 = "${var.project}"
  environment             = "${var.environment}"
  size                    = "${var.rds_size}"
  security_groups         = []
  rds_password            = "${var.rds_password}"
  multi_az                = "${var.rds_multiaz}"
  backup_retention_period = "${var.rds_retention_period}"
}
```
