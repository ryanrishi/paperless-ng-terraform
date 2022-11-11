resource "random_password" "paperless_secret_key" {
  length = 256
}

resource "aws_security_group" "web" {
  name_prefix = "paperless-ng-web-"

  ingress {
    from_port   = 80
    to_port     = 80
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
      paperless_redis      = "redis://${one(aws_elasticache_cluster.default.cache_nodes).address}:6379/paperless"
      paperless_dbhost     = aws_rds_cluster.default.endpoint
      paperless_dbuser     = aws_rds_cluster.default.master_username
      paperless_dbpassword = aws_rds_cluster.default.master_password
      paperless_secret_key = random_password.paperless_secret_key.result
      paperless_image_tag  = var.paperless_image_tag
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

resource "aws_instance" "default" {
  instance_type = "t3.micro"
  ami           = data.aws_ami.amazon_linux.id

  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = data.cloudinit_config.server_config.rendered
  key_name               = "ryan"
}

output "ec2_public_hostname" {
  value = aws_instance.default.public_dns
}
