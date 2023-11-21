variable "heading_one" {
    type =string
    default= "Azure Linux VM with Web Server"
}

variable "subnets" {
  default = [
    "Frontend",
    "Backend",
  ]
}