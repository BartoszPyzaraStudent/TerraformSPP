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
  region = "us-east-1"
}

# Wczytaj istniejącą rolę IAM
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# Pobierz sekret z AWS Secrets Manager
data "aws_secretsmanager_secret" "db_password" {
  name = "my-db-password"
}

data "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

locals {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_password_version.secret_string).password
}

# Lambda function from local ZIP
resource "aws_lambda_function" "my_lambda" {
  function_name = "my-exported-function"
  filename      = "lambda.zip"  # Twój lokalny plik ZIP
  source_code_hash = filebase64sha256("lambda.zip")  # Terraform wykryje zmiany

  handler = "index.handler"
  runtime = "python3.12"

  role = data.aws_iam_role.lab_role.arn

  # Przykładowo: podaj hasło jako zmienną środowiskową do Lambdy
  environment {
    variables = {
      DB_PASSWORD = local.db_password
    }
  }
}
