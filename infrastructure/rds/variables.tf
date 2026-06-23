variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "cluster_name" {
  type    = string
  default = "smartovate-intern-yassine"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets of the cluster VPC for the DB subnet group (>= 2 AZs)."
}

variable "db_username" {
  type    = string
  default = "smartovate"
}

variable "db_password" {
  type      = string
  sensitive = true
  # Prefer: export TF_VAR_db_password=... instead of putting it in tfvars.
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "engine_version" {
  type    = string
  default = "16"
  # Major-only resolves to the latest minor. To avoid plan drift, pin a full
  # version from: aws rds describe-db-engine-versions --engine postgres \
  #   --query 'DBEngineVersions[-1].EngineVersion' --output text
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "app_databases" {
  type        = list(string)
  default     = ["auth_db", "user_db", "crud_db"]
  description = "Created post-apply (RDS provisions only the default 'postgres' db)."
}
