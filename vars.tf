variable "paperless_image_tag" {
  description = "A tag from https://hub.docker.com/r/paperless-ngx/paperless-ngx/tags"
  default     = "latest"
}

variable "paperless_admin_user" {
  default = "admin"
}

variable "paperless_admin_password" {
  description = "Paperless admin password. If not provided, a random password will be generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "availability_zone" {
  # I don't really want to specify an AZ, but since `aws_ebs_volume` requires an AZ, we can't use `aws_instance.web.availability_zone` because the EC2 instance formats/mounts the EBS volume.
  # Alternatives considered: sleep in cloud-init (ew), run `terraform apply` + `tf taint aws_instance.web` + `tf apply`
  # Really want to keep cloud-init as the source of truth for what's going on in an instance
  #
  # As an unintentional benefit, removing the aws_instance dependency from aws_ebs_volume means that recreating the instance won't wipe out the volume.
  default = "us-west-2a"
}
