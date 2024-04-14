# Create SNS topic
resource "aws_sns_topic" "create_order_topic" {
  name = "create_order_topic_v1"
}