resource "aws_dynamodb_table" "connect_db" {
  name         = "connect-ec2"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "instanceid" # Partition Key
  range_key    = "action"     # Sort Key (Filter)

  attribute {
    name = "instanceid"
    type = "S" # String
  }

  attribute {
    name = "action"
    type = "S" # String
  }

  tags = {
    Name        = "connect-db"
    Environment = "Production"
  }
}