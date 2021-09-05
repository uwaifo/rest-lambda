# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "filename" {
  description = "The path to the function's deployment package within the local filesystem."
}

variable "function_name" {
  description = "A unique name for your Lambda Function."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "description" {
  description = "Description of what your Lambda Function does."
  default     = ""
}

variable "runtime" {
  description = "The runtime environment for the Lambda function you are uploading."
  default     = "go1.x"
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds. Defaults to 3."
  default     = 3
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128."
  default     = 128
}

# Provides the Lambda Function.
resource "aws_lambda_function" "lambda" {
  description                    = var.description
  filename                       = var.filename
  function_name                  = var.function_name
  handler                        = var.function_name
  memory_size                    = var.memory_size
  role                           = aws_iam_role.lambda.arn
  runtime                        = var.runtime
  source_code_hash               = filebase64sha256(var.filename)
  timeout                        = var.timeout
}

# Creates a IAM role for the Lambda function.
resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# Grants the Lambda function permission to to upload logs to CloudWatch.
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Constructs a JSON representation of the IAM policy document.
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Discover the name of the region configured within the provider.
data "aws_region" "current" {}


# ---------------------------------------------------------------------------------------------------------------------
# Info printed after a successful execution of the 'terraform apply' command.
# ---------------------------------------------------------------------------------------------------------------------
output "lambda_arn" {
  description = "The Amazon Resource Name identifying your Lambda Function."
  value       = aws_lambda_function.lambda.arn
}

output "lambda_function_name" {
  description = "The unique name of your Lambda Function."
  value       = aws_lambda_function.lambda.function_name
}

output "lambda_invoke_arn" {
  description = "The ARN to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri"
  value       = aws_lambda_function.lambda.invoke_arn
}

output "lambda_role_name" {
  description = "The name of the IAM attached to the Lambda Function."
  value       = aws_iam_role.lambda.name
}

output "lambda_version" {
  description = "Latest published version of your Lambda Function."
  value       = aws_lambda_function.lambda.version
}
