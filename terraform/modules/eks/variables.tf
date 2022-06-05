variable "vpc_id" {
    type = string
    description = "(optional) describe your variable"
}

variable "vpc_cidr_block" {
    type = string
    description = "(optional) describe your variable"
}

variable "subnet_ids" {
    type = list(string)
    description = "(optional) describe your variable"
}

variable "caller" {
    type = map(string)
    description = "(optional) describe your variable"
}

variable "instance_types" {
    type = list
    description = "(optional) describe your variable"
}

