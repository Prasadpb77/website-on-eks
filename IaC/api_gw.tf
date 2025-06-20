resource "aws_api_gateway_rest_api" "myapi" {
  name        = "myapp"
  description = "API Gateway with CORS Enabled"
}

# resource "aws_api_gateway_resource" "resource" {
#   rest_api_id = aws_api_gateway_rest_api.myapi.id
#   parent_id   = aws_api_gateway_rest_api.myapi.root_resource_id
#   path_part   = "data"
# }

# resource "aws_api_gateway_method" "options_method" {
#   rest_api_id   = aws_api_gateway_rest_api.myapi.id
#   resource_id   = aws_api_gateway_resource.resource.id
#   http_method   = "OPTIONS"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "options_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.myapi.id
#   resource_id             = aws_api_gateway_resource.resource.id
#   http_method             = aws_api_gateway_method.options_method.http_method
#   type                    = "MOCK"
#   request_templates       = { "application/json" = "{ \"statusCode\": 200 }" }
# }

# resource "aws_api_gateway_method_response" "options_response" {
#   rest_api_id = aws_api_gateway_rest_api.myapi.id
#   resource_id = aws_api_gateway_resource.resource.id
#   http_method = aws_api_gateway_method.options_method.http_method
#   status_code = "200"
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin" = true,
#     "method.response.header.Access-Control-Allow-Methods" = true,
#     "method.response.header.Access-Control-Allow-Headers" = true
#   }
# }

# resource "aws_api_gateway_method" "post_method" {
#   rest_api_id   = aws_api_gateway_rest_api.myapi.id
#   resource_id   = aws_api_gateway_resource.resource.id
#   http_method   = "POST"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "post_integration" {
#   rest_api_id = aws_api_gateway_rest_api.myapi.id
#   resource_id = aws_api_gateway_resource.resource.id
#   http_method = aws_api_gateway_method.post_method.http_method
#   type        = "AWS_PROXY"
#   uri         = aws_lambda_function.lambda1.invoke_arn
# }

# resource "aws_api_gateway_method" "get_method" {
#   rest_api_id   = aws_api_gateway_rest_api.myapi.id
#   resource_id   = aws_api_gateway_resource.resource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "get_integration" {
#   rest_api_id = aws_api_gateway_rest_api.myapi.id
#   resource_id = aws_api_gateway_resource.resource.id
#   http_method = aws_api_gateway_method.get_method.http_method
#   type        = "AWS_PROXY"
#   uri         = aws_lambda_function.lambda2.invoke_arn
#   depends_on = [ aws_api_gateway_method.get_method ]
# }

# resource "aws_api_gateway_deployment" "api_deploy" {
#   rest_api_id = aws_api_gateway_rest_api.myapi.id
#   stage_name  = "prod"
# }