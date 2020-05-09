###############################################################################################

provider "aws" {
    profile = "default"
    region = "us-east-2"
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

module "flowjoai_bucket" {
  source = "./modules/S3/flowjoai_bucket"
}
