data "aws_vpc" "default" {
  filter {
    name   = "tag:Name"
    values = ["ryanrishi-dev-us-west-2-vpc01"]
  }
}
