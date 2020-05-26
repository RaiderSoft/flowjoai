
variable "scan_on_push" {
  type        = bool
  description = "Whether to perform a security scan on newly pushed images"
  default     = true
}

variable "tag_mutability" {
  type        = string
  description = "Image tag mutability"
  default     = "MUTABLE"
}

variable "app_name" {
  type        = string
  description = "flowjoai"
}
