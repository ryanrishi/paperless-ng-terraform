resource "aws_elasticache_cluster" "default" {
  cluster_id      = "paperless"
  engine          = "redis"
  node_type       = "cache.t3.small"
  num_cache_nodes = 1
}
