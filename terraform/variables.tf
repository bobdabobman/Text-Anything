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
  default     = "text18449410220anything-cyware.com"
}

variable "log_retention_in_days" {
  description = "Number of days to retain logs in CloudWatch"
  default     = 5
}

variable "domain_name" {
  description = "The domain to register"
  type        = string
}

variable "contact_first_name" {
  description = "The contact's first name"
  type        = string
  default     = "Thomas"
}

variable "contact_last_name" {
  description = "The contact's last name"
  type        = string
  default     = "Zwinger"
}

variable "contact_address" {
  description = "The contact's address"
  type        = string
  default     = "405 Main St, Apt 303"
}

variable "contact_city" {
  description = "The contact's city"
  type        = string
  default     = "Red Wing"
}

variable "contact_state" {
  description = "The contact's state"
  type        = string
  default     = "MN"
}

variable "contact_country" {
  description = "The contact's country code"
  type        = string
  default     = "US"
}

variable "contact_zip" {
  description = "The contact's ZIP code"
  type        = string
  default     = "55066"
}

variable "contact_phone" {
  description = "The contact's phone number"
  type        = string
  default     = "+19526864444"
}

variable "contact_email" {
  description = "The contact's email"
  type        = string
  default     = "zwingthomas@gmail.com"
}

