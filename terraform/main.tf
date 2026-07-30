resource "aws_sqs_queue" "order_queue" {
  name = "order-queue"
}

resource "aws_sqs_queue" "notification_queue" {
  name = "notification-queue"
}

resource "aws_sns_topic" "order_notifications" {
  name = "order-notifications"
}

resource "aws_sns_topic_subscription" "notification_sub" {
  topic_arn = aws_sns_topic.order_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.notification_queue.arn
}

resource "aws_iam_role" "order_lambda_role" {
  name = "order-lambda-role-tf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "sns_publish_policy" {
  name = "SNSPublishPolicy"
  role = aws_iam_role.order_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.order_notifications.arn
      }
    ]
  })
}

resource "aws_lambda_function" "order_processor" {
  function_name = "order-processor-tf"
  runtime       = "python3.12"
  handler       = "lambda_function.handler"
  role          = aws_iam_role.order_lambda_role.arn
  filename      = "../function.zip"
  timeout       = 30
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.order_queue.arn
  function_name    = aws_lambda_function.order_processor.arn
  batch_size       = 1
}
