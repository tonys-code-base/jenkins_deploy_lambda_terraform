output "role_name" {
  description = "IAM role name"
  value       = aws_iam_role.iam_role_lambda.name
}

output "role_arn" {
  description = "IAM role arn"
  value       = aws_iam_role.iam_role_lambda.arn
}

output "policy_name" {
  description = "IAM policy name"
  value       = aws_iam_policy.iam_policy.name
}

output "policy_arn" {
  description = "IAM policy arn"
  value       = aws_iam_policy.iam_policy.arn
}

output "in_bucket" {
  description = "Input bucket"
  value       = aws_s3_bucket.in_bucket.id
}

output "out_bucket" {
  description = "Output bucket"
  value       = aws_s3_bucket.out_bucket.id
}

output "lambda_name" {
  description = "Function name"
  value       = aws_lambda_function.func.function_name
}

output "in_bucket_notification_config" {
  description = "Notification configuration"
  value       = aws_s3_bucket_notification.bucket_notification.lambda_function
}





