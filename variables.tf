variable "ipam_db_user" {
    description = "DB username for phpipam account"
    type = string
    default = "phpipam"
}

variable "ipam_db_name" {
    description = "DB name for ipam app"
    type = string
    default = "phpipam"
}

variable "http_port" {
    description = "TCP port to expose HTTP server"
    type = number
    default = 80
}

variable "https_port" {
    description = "TCP port to expose HTTPS server"
    type = number
    default = 443
}