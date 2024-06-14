variable "myregion" {
  description = "The AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "accountId" {
  description = "The AWS account ID"
  type        = string
}

variable "lambda_function_name" {
  description = "What to name the lambda function"
  type        = string
  default     = "onemap_getTheme"
}

variable "api_function1" {
  description = "The GET endpoint path"
  type        = string
  default     = "getTheme"
}
