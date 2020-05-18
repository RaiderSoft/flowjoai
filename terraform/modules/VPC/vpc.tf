# This tf file will build all VPC resources used by the flowjoai system

# TODO: Naming convention and tagging check
resource "aws_vpc" "sou-fjai" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "sm_subnet01" {
  # id = "subnet-2365434b"
  vpc_id            = "aws_vpc.sou-fjai.id"
  cidr_block        = "172.31.0.0/20"
  availability_zone = "us-east-2a"
  tags = {
    Name = "sou-fjai"
  }
}

resource "aws_subnet" "sm_subnet02" {
  # id  = "subnet-92fc60e8"
  vpc_id            = "aws_vpc.sou-fjai.id"
  cidr_block        = "172.31.16.0/20"
  availability_zone = "us-east-2b"
  tags = {
    Name = "sou-fjai"
  }
}

resource "aws_subnet" "sm_subnet03" {
  # id = "subnet-e22ce8ae" 
  vpc_id            = "aws_vpc.sou-fjai.id"
  cidr_block        = "172.31.32.0/20"
  availability_zone = "us-east-2c"
  tags = {
    Name = "sou-fjai"
  }
}

resource "aws_route_table" "rtb01" {
  # id               = "rtb-43c60128"
  # owner_id         = "914873542326"
  vpc_id = "aws_vpc.sou-fjai.id"
  route {
    cidr_block = "172.31.0.0/20"
    gateway_id = "aws_internet_gateway.igw01"
  }
  route {
    cidr_block = "172.31.16.0/20"
    gateway_id = "aws_internet_gateway.igw01"
  }
  route {
    cidr_block = "172.31.32.0/20"
    gateway_id = "aws_internet_gateway.igw01"
  }

  tags = {
    Name = "sou-fjai"
  }
}

resource "aws_internet_gateway" "igw01" {
  vpc_id = "aws_vpc.sou-fjai.id"
}

resource "aws_vpc_endpoint" "S3_ep01" {
  vpc_id       = "aws_vpc.sou-fjai.id"
  service_name = "com.amazonaws.us-east-2.s3"
  route_table_ids = [
    "rtb01",
  ]
}

resource "aws_security_group" "sg-inbound" {

  # description = "[DO NOT DELETE] Security Group that allows outbound NFS traffic for SageMaker Notebooks Domain [d-7a68jozvlpql]"
  vpc_id = "aws_vpc.sou-fjai.id"

  egress = [
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 2049
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups = [
        "sg-outbound",
      ]
      self    = false
      to_port = 2049
    },
  ]
  tags = {}
  # "ManagedByAmazonSageMakerResource" = "arn:aws:sagemaker:us-east-2:914873542326:domain/d-7a68jozvlpql"
}

resource "aws_security_group" "sg-outbound" {
  # description = "[DO NOT DELETE] Security Group that allows inbound NFS traffic for SageMaker Notebooks Domain [d-7a68jozvlpql]" -> "Managed by Terraform"
  vpc_id = "aws_vpc.sou-fjai.id"
  ingress = [
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 2049
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups = [
        "sg-inbound",
      ]
      self    = false
      to_port = 2049
    }
  ]
  tags = {}
  # "ManagedByAmazonSageMakerResource" = "arn:aws:sagemaker:us-east-2:914873542326:domain/d-7a68jozvlpql"
}

resource "aws_network_acl" "acl01" {
  # id         = "acl-3ba6bc53"
  # owner_id   = "914873542326"
  vpc_id = "aws_vpc.sou-fjai.id"
  subnet_ids = [
    "sm_subnet01",
    "sm_subnet02",
    "sm_subnet03"
  ]
  # tags       = {}
}
