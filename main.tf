terraform {
  backend "s3" {
    bucket         = "terraformbackedndbucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraformbackenddb"
    encrypt        = true
  }
}



provider "aws" {
  region                  = "us-east-1"
}





# Wczytaj istniejącą rolę IAM
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# Lambda function from local ZIP
resource "aws_lambda_function" "my_lambda" {
  function_name = "my-exported-function"
  filename      = "lambda.zip"  # <- Twój lokalny plik
  source_code_hash = filebase64sha256("lambda.zip")  # Terraform wie, kiedy zip się zmieni

  handler = "index.handler"  # <- Zmień jeśli inna funkcja startowa
  runtime = "python3.12"     # <- Zmień jeśli inny język

  role = data.aws_iam_role.lab_role.arn  # <- Użycie istniejącej roli IAM
}
