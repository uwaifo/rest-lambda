# A Lambda function is not a usual public REST API. We need to use AWS API
# Gateway to map a Lambda function to an HTTP endpoint.
resource "aws_api_gateway_resource" "pms-rest-api" {
  rest_api_id = aws_api_gateway_rest_api.pms-rest-api.id
  parent_id   = aws_api_gateway_rest_api.pms-rest-api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_rest_api" "pms-rest-api" {
  name = "pms-rest-api"
}

#           GET
# Internet -----> API Gateway
resource "aws_api_gateway_method" "pms-rest-api" {
  rest_api_id = aws_api_gateway_rest_api.pms-rest-api.id
  resource_id = aws_api_gateway_resource.pms-rest-api.id
  // http_method   = "GET"
  http_method        = "ANY"
  authorization      = "NONE"
  request_parameters = { "method.request.path.proxy" = true }
}

#              POST
# API Gateway ------> Lambda
# For Lambda the method is always POST and the type is always AWS_PROXY.
#
# The date 2015-03-31 in the URI is just the version of AWS Lambda.
resource "aws_api_gateway_integration" "pms-rest-api" {
  rest_api_id             = aws_api_gateway_rest_api.pms-rest-api.id
  resource_id             = aws_api_gateway_resource.pms-rest-api.id
  http_method             = aws_api_gateway_method.pms-rest-api.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.pms-rest-api-lambda.arn}/invocations"
}

# This resource defines the URL of the API Gateway.
resource "aws_api_gateway_deployment" "api_v1" {
  depends_on = [
    aws_api_gateway_integration.pms-rest-api
  ]
  rest_api_id = aws_api_gateway_rest_api.pms-rest-api.id
  stage_name  = "dev"
}

