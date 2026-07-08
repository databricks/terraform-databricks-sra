data "aws_availability_zones" "available" {
  count = local.is_serverless ? 0 : 1
  state = "available"
}