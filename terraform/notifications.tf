// SYSTEMS SNS
resource "aws_sns_topic" "pms-system-notifications" {
  name = "pms-system-notififaction"
}

// TASKS SNS
resource "aws_sns_topic" "pms-task-notifications" {
  name = "pms-task-notifications"
}

// TASK SQS
resource "aws_sqs_queue" "pms-task-records" {
  name = "pms-task-records"
}
/*
//
resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "pms-ws-yardi-lambda"
  principal     = "sns.amazonaws.com"
}

resource "aws_sns_topic_subscription" "invoke_with_sns" {
  topic_arn = aws_sns_topic.pms-task-notifications.arn
  protocol  = "lambda"
  //endpoint  = var.yardi_lambda_arn
  endpoint = aws_lambda_function.pms-ws-yardi-lambda.arn
}
*/