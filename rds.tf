resource "random_password" "password" {
  length = 20
}

resource "aws_security_group" "rds" {
  name_prefix = "paperless-ng-to-rds-"

  ingress {
    description = "Allow paperless-ng instances to access the database"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [
      aws_security_group.web.id
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster" "default" {
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = "14.5"
  database_name      = "paperless"
  cluster_identifier = "paperless"
  master_username    = "postgres"
  master_password    = random_password.password.result

  backup_retention_period = 7
  skip_final_snapshot     = true

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]
}

resource "aws_rds_cluster_instance" "instance" {
  cluster_identifier = aws_rds_cluster.default.id
  engine             = "aurora-postgresql"
  instance_class     = "db.t3.medium"
}
