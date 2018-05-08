variable "user" {
  type        = "string"
  description = "User name to be used to namespace resources"
}

variable "key_name" {
  type        = "string"
  description = "A keypair name to be used to launch the bitcoind EC2 instance"
  default     = ""
}
