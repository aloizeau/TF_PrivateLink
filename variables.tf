variable "environment" {
  description = "(Optional) Environment in which the resources will be created."
  type        = string
  default     = "sbx"
  validation {
    condition     = contains(["sbx", "uat", "ppa", "pr"], var.environment)
    error_message = "Sorry, but we only accept 'sbx', 'uat', 'ppa' or 'pr' environments."
  }
}