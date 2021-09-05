variable "api_name" {
  description = "The name of the associated REST API"
  default     = "DUMMY_API_NAME"
}

variable "resource_method" {
  description = "The resource HTTP method"
  default     = "POST"
}

variable "resource_path" {
  description = "The resource path"
  default     = "{proxy+}"
}

variable "account_id" {
  description = "The AWS account ID"
  default     = "000000000000"
}

# Creates the ReST API.
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
}

# ReST API requires at least one "endpoint", or "resource" in AWS terminology.
resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.resource_path
}

# Defines the resource HTTP method (verb or action).
resource "aws_api_gateway_method" "resource_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = var.resource_method
  authorization = "NONE"
}

# Integrates the resource (with the specified verb) into the ReST API.
resource "aws_api_gateway_integration" "resource_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.resource_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda.invoke_arn
  #uri        = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
}


# Deploy the ReST API (i.e. make it publicly available).
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "stage"
  depends_on  = [aws_api_gateway_method.resource_method, aws_api_gateway_integration.resource_integration]
}

# Gives the API Gatewat permissions to invoke Lambda functions.
resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = aws_lambda_function.lambda.arn
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  #source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.resource_method.http_method}/${aws_api_gateway_resource.resource.path}"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

# Prints the deployes resource URL.
output "resource_url" {
  value = "${var.localstack_url}/restapis/${aws_api_gateway_rest_api.api.id}/stage/_user_request_/${aws_api_gateway_resource.resource.path_part}"
}

# Prints a sample curl command (just to do a quick copy an paste test).
output "curl_command" {
  value = "curl --header \"Content-Type: application/json\" --request ${var.resource_method} --data '{\"username\":\"xyz\",\"password\":\"xyz\"}' ${var.localstack_url}/restapis/${aws_api_gateway_rest_api.api.id}/stage/_user_request_/${aws_api_gateway_resource.resource.path_part}"
}

