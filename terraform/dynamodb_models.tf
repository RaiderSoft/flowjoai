resource "aws_dynamodb_table" "flowjoai-models" {
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

  # ttl {
  #   attribute_name = "TimeToExist"
  #   enabled        = false
  # }

  tags = {
    Name        = "flowjoai-models"
    Environment = "production"
  }
}
