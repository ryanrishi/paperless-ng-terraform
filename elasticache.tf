resource "aws_security_group" "elasticache" {
  name_prefix = "paperless-ng-to-elasticache-"

  ingress {
    description = "Allow paperless-ng instances to access ElastiCache"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [
      aws_security_group.web.id
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elasticache_cluster" "default" {
  cluster_id      = "paperless"
  engine          = "redis"
  node_type       = "cache.t3.small"
  num_cache_nodes = 1
  security_group_ids = [
    aws_security_group.elasticache.id
  ]
}
