###############################################################################################

provider "aws" {
    profile = "default"
    region = "us-east-2"
}

###############################################################################################

module "flowjoai-vpc" {
  source = "./modules/VPC"
}

###############################################################################################

module "flowjoai-websocket" {
  source = "./modules/GatewayAPI/flowjoai-websocket"
}

###############################################################################################

module "flowjoai_models" {
  source = "./modules/DynamoDB/flowjoai_models"
}

module "flowjoai_clients" {
  source = "./modules/DynamoDB/flowjoai_clients"
}

###############################################################################################
# NOTE: S3 only likes hyphens, no underscores
module "flowjoai-bucket" {
  source = "./modules/S3/flowjoai_bucket"
}
module "flowjoai-ecr" {
  source = "./modules/ECR"
}