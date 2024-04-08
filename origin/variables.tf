variable "aws_region" {
  description = "The AWS region. It will be used by the AWS provider."
  default     = "eu-west-1"
}

variable "aws_access_key" {
  description = "AWS access key. It will be used by the AWS provider."
  default     = "AKIAIOSFODNN7EXAMPLE"
}

variable "aws_secret_key" {
  description = "AWS secret key. It will be used by the AWS provider."
  default     = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

variable "aws_caller_identity" {
  default     = "000000000000"
  description = "A 12-digit number, such as 012345678901, that uniquely identifies an AWS account."
}
