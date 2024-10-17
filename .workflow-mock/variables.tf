variable "trigger_value" {
  type        = string
  default     = "test"
  description = "Changing this value will trigger a replace on the null_resource"
}
