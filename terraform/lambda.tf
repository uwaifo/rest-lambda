// COMPILE THE LAMBDA FUNCTIONS
resource "null_resource" "compile" {
  triggers = {
    build_number = timestamp()
  }
 
  // minigin
  provisioner "local-exec" {
    command = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ../target/pms-rest-api-lambda-bin -ldflags '-w' ../cmd/main.go"
  }
}

// ZIP LAMBDA CODE
data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "../target/"
  output_path = "../target/lambdabin.zip"
  depends_on  = [null_resource.compile]
}

# DEFINE LAMBDA FUNCTIONS

# The handler is the name of the executable for go1.x runtime.
// NOTICE
resource "aws_lambda_function" "pms-rest-api-lambda" {
  function_name    = "pms-rest-api-lambda"
  handler          = "pms-rest-api-lambda-bin"
  runtime          = "go1.x"
  role             = aws_iam_role.pms-rest-lambda-role.arn
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  memory_size      = 128
  timeout          = 20
  environment {
    variables = {
      APP_ENV        = "production"
      SYSTEM_SNS_ARN = aws_sns_topic.pms-system-notifications.arn
      TASK_SNS_ARN   = aws_sns_topic.pms-task-notifications.arn
      REGION         = var.region
      DB_DRIVER      = var.database_engine
      DB_PASSWORD    = var.database_password
      DB_USERNAME    = var.database_username
      DB_DBNAME      = var.dev_database_name
    DB_URL = "tgpisdevdb.chqiulfy2dsu.us-east-1.rds.amazonaws.com" }
  }
}

# ADD ROLE TO THE LAMBDA FUNCTION
resource "aws_iam_role" "pms-rest-lambda-role" {
  name               = "pms-rest-lambda-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": {
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    },
    "Effect": "Allow"
  }
}
POLICY
}


# Allow API gateway to invoke the RESR API Lambda function.
resource "aws_lambda_permission" "allow_api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pms-rest-api-lambda.arn
  principal     = "apigateway.amazonaws.com"
  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  //source_arn = "${aws_api_gateway_rest_api.pms-rest-api.execution_arn}/*/*"
  source_arn = "${aws_api_gateway_rest_api.pms-rest-api.execution_arn}/*/*/*"

}


