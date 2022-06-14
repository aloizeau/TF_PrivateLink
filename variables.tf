variable "environment" {
  description = "(Optional) Environment in which the resources will be created."
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "uat", "pp", "pr"], var.environment)
    error_message = "Sorry, but we only accept 'dev', 'uat', 'pp' or 'pr' environments."
  }
}