variable "auto_sync" {
  type    = bool
  default = true
}

variable "blue_version" {
  type = string
}

variable "is_blue_up" {
  type = bool
}

variable "green_version" {
  type = string
}

variable "is_green_up" {
  type = bool
}

variable "route_to_color" {
  type = string

  validation {
    condition     = contains(["blue", "green"], var.route_to_color)
    error_message = "Must be one of `blue` or `green`."
  }
}
