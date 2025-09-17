output "aws_dynamodb_table_name" {
  value = aws_dynamodb_table.main.id                                         # The actual value to be outputted
  description = "The public IP address of the EC2 instance" # Description of what this output represents
}