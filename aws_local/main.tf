provider "aws" {
  region                      = var.aws_region
  profile                     = var.aws_profile
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  insecure                    = true
  
  endpoints {
    acm            = "https://localstack:4566"
    apigateway     = "https://localstack:4566"
    cloudformation = "https://localstack:4566"
    cloudwatch     = "https://localstack:4566"
    dynamodb       = "https://localstack:4566"
    ec2            = "https://localstack:4566"
    es             = "https://localstack:4566"
    firehose       = "https://localstack:4566"
    iam            = "https://localstack:4566"
    kinesis        = "https://localstack:4566"
    kms            = "https://localstack:4566"
    lambda         = "https://localstack:4566"
    rds            = "https://localstack:4566"
    route53        = "https://localstack:4566"
    s3             = "https://localstack:4566"
    secretsmanager = "https://localstack:4566"
    ses            = "https://localstack:4566"
    sns            = "https://localstack:4566"
    sqs            = "https://localstack:4566"
    ssm            = "https://localstack:4566"
    stepfunctions  = "https://localstack:4566"
    sts            = "https://localstack:4566"
  }
}

# Create IAM role with trust relationship for lambda service

resource "aws_iam_role" "iam_role_lambda" {
  name = var.app_name

  assume_role_policy = file("${path.module}/../my-lambda/iam/lambda_iam_trust_policy.json")
}

# IAM policy template

data "template_file" "lambda_iam_policy" {
  template = file("${path.module}/../my-lambda/iam/lambda_iam_policy.json")
  vars = {
    app_name    = var.app_name
    aws_region  = var.aws_region
    aws_account = var.aws_account
  }
}

# Create the policy

resource "aws_iam_policy" "iam_policy" {
  name        = var.app_name
  path        = "/"
  description = "IAM policy for lambda"
  policy      = data.template_file.lambda_iam_policy.rendered
}

# Attach policy to IAM role

resource "aws_iam_role_policy_attachment" "policy_for_lambda" {
  role       = aws_iam_role.iam_role_lambda.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

# Input bucket used by Lambda

resource "aws_s3_bucket" "in_bucket" {
  bucket = "${var.app_name}-input"
}

# Output bucket used by lambda

resource "aws_s3_bucket" "out_bucket" {
  bucket = "${var.app_name}-output"
}

# Create Lambda function

resource "aws_lambda_function" "func" {
  filename      = "../dist/${var.lambda_zip}"
  function_name = var.app_name
  role          = aws_iam_role.iam_role_lambda.arn
  handler       = "my-lambda.lambda_handler"
  
  depends_on = [
    aws_iam_role_policy_attachment.policy_for_lambda
  ]  

  source_code_hash = filebase64sha256("../dist/${var.lambda_zip}")

  runtime = "python3.8"

# Lambda function environment variables

  environment {
    variables = {
      OUTPUT_BUCKET     = "${var.app_name}-output"
      DEPLOYMENT_TARGET = var.env
    }
  }
}

# Add permissions to allow s3 to trigger lambda function

resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowTriggerFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.in_bucket.arn
}

# Configure bucket notification for triggering lambda 
# when s3 csv file uploaded to input bucket

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.in_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    id                  = "s3_trigger"
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = "csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_trigger]
}