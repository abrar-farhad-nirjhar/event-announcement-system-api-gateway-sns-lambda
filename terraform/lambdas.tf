
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas"
  output_path = "${path.module}/lambda/lambdas.zip"
}

resource "aws_lambda_function" "subscribe" {
  function_name    = "subscription_handler"
  handler          = "app.subscription_handler"
  runtime          = "python3.13"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  filename         = data.archive_file.lambda_zip.output_path

  environment {
    # SNS_TOPIC_ARN = aws_sns_topic.event_announcements.arn
  }
}


resource "aws_lambda_function" "notify" {
  function_name    = "notification_handler"
  handler          = "app.notification_handler"
  runtime          = "python3.13"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  filename         = data.archive_file.lambda_zip.output_path

  environment {
    # SNS_TOPIC_ARN = aws_sns_topic.event_announcements.arn
  }

}
