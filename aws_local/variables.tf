# AWS Region
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Application name to include in names of AWS resources

variable "app_name" {
  type    = string
  default = "transposer"
}

# AWS Account (for Localstack, value is zeroes)

variable "aws_account" {
  type    = string
  default = "000000000000"
}

# AWS profile to source credentials

variable "aws_profile" {
  type    = string
  default = "aws_local"
}

# Source name and location containing Lambda zip.
# Zip is created during the Jenkins pipeline.

variable "lambda_zip" {
  type    = string
  default = "../dist/src.zip"
}

# Deployment target - AWS Cloud (aws_cloud)
# or Localstack (aws_local)

variable "env" {
  description = "Env - localstack or cloud"
  type        = string
  default     = "aws_local"
}