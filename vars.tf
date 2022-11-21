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
