###############################################################################################

provider "aws" {
    profile = "default"
    region = var.aws_region
}

###############################################################################################

# It doesn't look like this is actually needed by any resources so
# we can just remove it
# module "flowjoai-vpc" {
#   source = "./modules/VPC"
# }

###############################################################################################

module "flowjoai-websocket" {
  source = "./modules/GatewayAPI/flowjoai-websocket"
  
  app_name    = var.app_name
}

###############################################################################################

module "flowjoai_models" {
  source = "./modules/DynamoDB/flowjoai_models"

  app_name = var.app_name
}

module "flowjoai_clients" {
  source = "./modules/DynamoDB/flowjoai_clients"

  app_name = var.app_name
}

###############################################################################################
# NOTE: S3 only likes hyphens, no underscores
module "flowjoai-bucket" {
  source = "./modules/S3/flowjoai_bucket"

  app_name = var.app_name
}
module "flowjoai-ecr" {
  source = "./modules/ECR"
  
  app_name = var.app_name
}

# Set up remote state storage
terraform {
  backend "s3" {
    bucket         = "bdbi-terraform"
    key            = "flowjoai/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform_lock_db"
    encrypt        = true
  }
}
