# Create SQS queue
resource "aws_sqs_queue" "create_order_queue" {
  name                       = "create_order_queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600 # 4 days
  visibility_timeout_seconds = 301
}

# SQS queue policy
resource "aws_sqs_queue_policy" "create_order_queue_policy" {
  queue_url = aws_sqs_queue.create_order_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "create-order-sqs-policy",
    Statement = [{
      Sid       = "Allow-SNS-SendMessage",
      Effect    = "Allow",
      Principal = "*",
      Action    = "sqs:SendMessage",
      Resource  = aws_sqs_queue.create_order_queue.arn,
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.create_order_topic.arn
        }
      }
    }]
  })
}
# Subscribe SQS queue to SNS topic
resource "aws_sns_topic_subscription" "create_order_subscription" {
  topic_arn = aws_sns_topic.create_order_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.create_order_queue.arn

  depends_on = [aws_sns_topic.create_order_topic] # Ensure subscription is created after the topic

  filter_policy = jsonencode({
    "eventType" : [
      "order_created"
    ]
  })
}

resource "aws_lambda_event_source_mapping" "example_mapping" {
  event_source_arn = aws_sqs_queue.create_order_queue.arn
  function_name    = aws_lambda_function.example_lambda.function_name
  enabled          = true
}

# Create SQS subscription filter policy
# resource "aws_sns_topic_subscription" "create_order_filter_policy" {
#   topic_arn = aws_sns_topic.create_order_topic.arn
#   protocol  = "sqs"
#   endpoint  = aws_sqs_queue.create_order_queue.arn
#   filter_policy = jsonencode({
#     "eventType" : ["order_created"]
#   })
# }
