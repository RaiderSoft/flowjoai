#
# Table to store all models sessions as they connect to websocket
#

###############################################################################################

######## ------ flowjoai_models ------ ######## START

resource "aws_dynamodb_table" "flowjoai_models" {
  name           = "models"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "uuid"
  range_key      = "created"

  attribute {
    name = "uuid"
    type = "S"
  }

  attribute {
    name = "created"
    type = "S"
  }
  
  tags = {
    Name        = "flowjoai_models"
    Environment = "production"
  }
}

######## ------ flowjoai_models ------ ######## END

output "flowjoai_models" {
  value = aws_dynamodb_table.flowjoai_models
}

###############################################################################################

