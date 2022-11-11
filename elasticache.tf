resource "aws_security_group" "elasticache" {
  name_prefix = "paperless-ng-to-elasticache-"
  # vpc_id      = data.aws_vpc.default.id

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

# resource "aws_elasticache_subnet_group" "default" {
#   name       = "paperless-elasticache-subnet-group"
#   subnet_ids = [aws_subnet.subnet.id]
# }

resource "aws_elasticache_cluster" "default" {
  cluster_id = "paperless"
  # subnet_group_name = aws_elasticache_subnet_group.default.name
  engine          = "redis"
  node_type       = "cache.t3.small"
  num_cache_nodes = 1
  security_group_ids = [
    aws_security_group.elasticache.id
  ]
}
