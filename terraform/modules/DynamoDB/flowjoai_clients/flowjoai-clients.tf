#
# Table to store all clients sessions as they connect to websocket
#

###############################################################################################

######## ------ flowjoai-clients ------ ######## START

resource "aws_dynamodb_table" "flowjoai_clients" {
  name           = "${var.app_name}-clients-${terraform.workspace}"
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
    Name        = "flowjoai_clients"
    Environment = "production"
  }
}

######## ------ flowjoai-clients ------ ######## END

output "flowjoai_clients" {
  value = aws_dynamodb_table.flowjoai_clients
}

###############################################################################################

