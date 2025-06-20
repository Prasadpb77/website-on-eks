resource "aws_iam_role" "lambda_role" {
  name = "LambdaDynamoDBRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_dynamodb_policy" {
  name       = "LambdaDynamoDBPolicyAttachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_policy_attachment" "lambda_dynamodb_policy_2" {
  name       = "LambdaDynamoDBPolicyAttachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::920013188018:policy/service-role/AWSLambdaBasicExecutionRole-ea94509f-b57c-4f1d-a301-ac12ad4df0a7"
}

resource "aws_lambda_function" "lambda1" {
  function_name    = "frontend"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "insert_data.lambda_handler"
  filename         = "lambda/lambda1.zip"
  source_code_hash = filebase64sha256("lambda/lambda1.zip")
}

resource "aws_lambda_function" "lambda2" {
  function_name    = "dashboard"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "display_data.lambda_handler"
  filename         = "lambda/lambda2.zip"
  source_code_hash = filebase64sha256("lambda/lambda2.zip")
}
