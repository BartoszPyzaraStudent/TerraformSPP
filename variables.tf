variable "aws_region" {
  description = "AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  default     = "default"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  default     = "terraformbackedndbucket"
}
