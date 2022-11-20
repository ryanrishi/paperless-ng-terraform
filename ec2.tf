resource "random_password" "paperless_secret_key" {
  length = 256
}

resource "random_password" "paperless_admin_password" {
  count  = var.paperless_admin_password == null ? 1 : 0
  length = 32
}

locals {
  paperless_admin_password = coalesce(var.paperless_admin_password, one(random_password.paperless_admin_password[*].result))
}

resource "aws_security_group" "web" {
  name_prefix = "paperless-ng-web-"

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TODO use a bastion
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "cloudinit_config" "server_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/server.yml", {
      paperless_redis          = "redis://${one(aws_elasticache_cluster.default.cache_nodes).address}:6379/0"
      paperless_dbhost         = aws_rds_cluster.default.endpoint
      paperless_dbuser         = aws_rds_cluster.default.master_username
      paperless_dbpassword     = aws_rds_cluster.default.master_password
      paperless_secret_key     = random_password.paperless_secret_key.result
      paperless_image_tag      = var.paperless_image_tag
      paperless_admin_user     = var.paperless_admin_user
      paperless_admin_password = local.paperless_admin_password
    })
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2"
    ]
  }
}

resource "aws_instance" "web" {
  instance_type = "t3.micro"
  ami           = data.aws_ami.amazon_linux.id

  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = data.cloudinit_config.server_config.rendered
  key_name               = "ryan"
}

resource "aws_eip" "elastic_ip" {
  instance = aws_instance.web.id
  vpc      = true
}

output "public_dns" {
  value = aws_eip.elastic_ip.public_dns
}

output "paperless_admin_password" {
  value     = local.paperless_admin_password
  sensitive = true
}
