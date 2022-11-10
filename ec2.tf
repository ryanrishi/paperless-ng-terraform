resource "aws_security_group" "default" {
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
}

data "cloudinit_config" "server_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/server.yml", {
      paperless_redis     = one(aws_elasticache_cluster.default.cache_nodes).address
      paperless_dbhost    = aws_rds_cluster.default.endpoint
      paperless_image_tag = var.paperless_image_tag
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

  vpc_security_group_ids = [aws_security_group.default.id]
  user_data              = data.cloudinit_config.server_config.rendered
  key_name               = "ryan"
}

output "ec2_public_hostname" {
  value = aws_instance.default.public_dns
}
