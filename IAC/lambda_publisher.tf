data "archive_file" "lambda_function_code" {
  type        = "zip"
  source_dir  = "../packages/create-order-publisher"
  output_path = "../output/create-order-publisher.zip"
}

resource "aws_lambda_function" "lambda_publisher" {
  filename      = data.archive_file.lambda_function_code.output_path
  function_name = "create-order-publisher-lambda"
  role          = aws_iam_role.lambda_publisher_role.arn
  handler          = "create_lambda_publisher.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.lambda_function_code.output_base64sha256
}

resource "aws_iam_role" "lambda_publisher_role" {
  name = "create-order-publisher-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_publisher_policy" {
  name        = "create-order-publisher-lambda-policy"
  description = "Policy for create order publish Lambda function"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "logs:*",
        "sns:Publish"
      ]
      Resource = [
        "arn:aws:logs:*:*:*",
        "arn:aws:sns:ap-south-1:471112983152:create_order_topic_v1"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_publisher_policy_attachment" {
  role       = aws_iam_role.lambda_publisher_role.name
  policy_arn = aws_iam_policy.lambda_publisher_policy.arn
}
