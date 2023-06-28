variable "random_postfix_length" {
  type    = string
  default = 8
}

variable "dns_list" {
    type = list(string)
}
