variable "AWS_ACCESS_KEY" {
  default = ""
}

variable "AWS_SECRET_KEY" {
  default = ""
}

variable "AWS_REGION" {
  default     = "eu-central-1"
  description = "Europe (Frankfurt) Region"
}

variable "EC2_AMI_ID" {
  default = "ami-0a5b5c0ea66ec560d"
}

variable "EC2_INSTANCE_TYPE" {
  default = "t2.micro"
}

variable "TLS_PRIVATE_KEY_NAME" {
  default = "transifex"
}

