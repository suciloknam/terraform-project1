data "aws_key_pair" "existing_key" {
    key_name = "newkey"
}

data "aws_vpc" "default" {
  default = true
}
data "aws_subnet" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
