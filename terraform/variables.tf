variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  default     = "hello-world-app"
}

variable "twilio_auth_token" {
  description = "Twilio Auth Token"
  type        = string
  sensitive = true
}

variable "twilio_account_sid" {
  description = "Twilio Account SID"
  type        = string
  sensitive   = true
}

variable "twilio_phone_number" {
  description = "Twilio phone number"
  type        = string
  default     = 18449410220
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  default     = 1
}

variable "domain_name" {
  description = "The domain name for the application"
  default     = "text18449410220anything.com"
}

variable "log_retention_in_days" {
  description = "Number of days to retain logs in CloudWatch"
  default     = 5
}

