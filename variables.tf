variable "public_subnet_webserver" {

  type = list(string)

  description = "Public Subnet CIDR values"

  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]

}



variable "private_subnet_webserver" {

  type = list(string)

  description = "Private Subnet CIDR values"

  default = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]

}

variable "azs" {

  type = list(string)

  description = "Availability Zones"

  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]

}

variable "Keypair" {
  type    = string
  default = "<replace value>"
}

variable "sg_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "allow http"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "allow https"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "10.1.0.0/16"
      description = "allow ssh on local network"
    }
  ]
}