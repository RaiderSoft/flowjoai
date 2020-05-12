# Placeholder vpc.tf

# Creates the main VPC and 3 subnets across 3 availability zones connected to a route table
# flowjoai-create-model specifies subnets for sagemaker


resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
}

###############################################################################################
######## ------ subnet setup ------ ######## START
# TODO: Needs 3 subnets to cover availability zones (should verify, may only need 2)
## flowjoai-create-model
variable "subnet01_id" {}
variable "subnet02_id" {}
variable "subnet03_id" {}

resource "aws_subnet" "aws_subnet01" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = ""
}

resource "aws_subnet" "aws_subnet02" {
  vpc_id     = "${aws_vpc.main.id}"
  # cidr_block = "10.0.1.0/24"
  availability_zone = ""

}

resource "aws_subnet" "aws_subnet03" {
  vpc_id     = "${aws_vpc.main.id}"
  # cidr_block = "10.0.1.0/24"
  availability_zone = ""

}

######## ------ subnet ------ ######## END
###############################################################################################

###############################################################################################
######## ------ route table setup ------ ######## START
# Allows sagemaker resources to connect to other amazon services (s3) across subnets/availability zones



# TODO: Implement

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = "${aws_egress_only_internet_gateway.foo.id}"
  }

  tags = {
    Name = "main"
  }
}


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.foo.id
  route_table_id = aws_route_table.bar.id
}
resource "aws_route_table_association" "b" {
  gateway_id     = aws_internet_gateway.foo.id
  route_table_id = aws_route_table.bar.id
}
resource "aws_route_table_association" "c" {
  gateway_id     = aws_internet_gateway.foo.id
  route_table_id = aws_route_table.bar.id
}

######## ------ subnet ------ ######## END
###############################################################################################

# data "aws_vpc" "vpc" {
#   filter {
#     name   = "tag:Name"
#     values = [var.vpc_name]
#   }
# }
# data "aws_subnet_ids" "private" {
#   tags = {
#     "type" = "private"
#   }
#   vpc_id = data.aws_vpc.vpc.id
# }
# data "aws_subnet" "private" {
#   count = length(data.aws_subnet_ids.private.ids)
#   id    = tolist(data.aws_subnet_ids.private.ids)[count.index]
# }
# If you want to reference directly from subnet ids
# data.aws_subnet_ids.private.*.ids

