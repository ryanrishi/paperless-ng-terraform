resource "random_password" "password" {
  length = 20
}

resource "aws_rds_cluster" "cluster" {
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = "14.5"
  database_name      = "paperless"
  cluster_identifier = "paperless"
  master_username    = "postgres"
  master_password    = random_password.password.result

  backup_retention_period = 7
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "instance" {
  cluster_identifier = aws_rds_cluster.cluster.id
  engine             = "aurora-postgresql"
  instance_class     = "db.t3.medium"
}

resource "aws_elasticache_cluster" "default" {
  cluster_id      = "paperless"
  engine          = "redis"
  node_type       = "cache.t3.small"
  num_cache_nodes = 1
}
