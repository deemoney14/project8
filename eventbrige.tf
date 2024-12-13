resource "aws_lambda_function" "cleanup_function" {
  filename         = "lambda_function.zip"
  function_name    = "ebs-snapshot-cleanup"
  role             = aws_iam_role.lambda_role.arn
  handler          = "ebs_state_snapshots.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("lambda_function.zip")
  timeout          = 20
}

resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name                = "ebs-snapshot-cleanup-schedule"
  description         = "Run immediately for testing purposes"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  target_id = "lambda"
  arn       = aws_lambda_function.cleanup_function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cleanup_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_rule.arn
}


output "lambda_function_arn" {
  value = aws_lambda_function.cleanup_function.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.cleanup_function.function_name
}
