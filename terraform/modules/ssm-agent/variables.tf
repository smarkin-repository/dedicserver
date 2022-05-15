variable "vpc_id" {
    type = string
    description = "(optional) describe your variable"
}

variable "subnet_ids" {
    type = list(string)
    description = "(optional) describe your variable"
}

variable "user_data" {
    type = string
    description = "(optional) describe your variable"
}

variable "ami" {
    type = string
    description = "(optional) describe your variable"
    default = ""
}

variable "instance_type" {
    type = string
    description = "(optional) describe your variable"
    default = "t3.micro"
}

variable "additional_security_group_ids" {
    type = list(string)
    description = "(optional) describe your variable"
    default = []
}

variable "max_instance_count" {
    type = number
    default = 1
}

variable "min_instance_count" {
    type = number
    default = 0
}

variable "desired_instance_count" {
    type = number
    default = 1
}

variable "tags" {
    type = map(string)
    description = "(optional) describe your variable"
}