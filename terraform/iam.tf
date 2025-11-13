
resource "aws_iam_role" "lambda_exec" {
  name               = "lambda_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}


data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "lambda_logging_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name   = "lambda_logging_policy"
  policy = data.aws_iam_policy_document.lambda_logging_policy.json
}


resource "aws_iam_role_policy_attachment" "lambda_logging_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}


data "aws_iam_policy_document" "sns_access_policy" {
  statement {
    actions = [
      "sns:Publish",
      "sns:Subscribe",
    ]
    resources = [aws_sns_topic.event_announcements.arn]
  }
}

resource "aws_iam_policy" "sns_access_policy" {
  name   = "sns_access_policy"
  policy = data.aws_iam_policy_document.sns_access_policy.json
}


resource "aws_iam_role_policy_attachment" "sns_access_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.sns_access_policy.arn
}
