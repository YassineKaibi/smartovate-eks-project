# Derive VPC and the EKS-managed cluster security group from the running cluster,
# so nothing about the network is hardcoded here.
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

locals {
  vpc_id     = data.aws_eks_cluster.this.vpc_config[0].vpc_id
  cluster_sg = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id

  tags = {
    project = "smartovate-eks-internship"
    owner   = "yassine"
    env     = "staging"
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.cluster_name}-rds"
  subnet_ids = var.private_subnet_ids
  tags       = local.tags
}

resource "aws_security_group" "rds" {
  name        = "${var.cluster_name}-rds"
  description = "Postgres access from EKS cluster nodes/pods"
  vpc_id      = local.vpc_id
  tags        = local.tags
}

# Nodes (and, with the default VPC CNI, pods) carry the cluster security group,
# so referencing it as the source is enough to let workloads reach the DB.
resource "aws_vpc_security_group_ingress_rule" "pg_from_cluster" {
  security_group_id            = aws_security_group.rds.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = local.cluster_sg
  description                  = "Postgres 5432 from EKS cluster SG"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.rds.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_db_instance" "this" {
  identifier     = "${var.cluster_name}-pg"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  # Throwaway internship posture: cheap and easy to tear down.
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  tags = local.tags
}
