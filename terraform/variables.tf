variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  default = "Terraform_1"
}

variable "peer_vpc_id" {
  description = "The ID of the existing VPC to peer with"
  default     = "vpc-02a507c401bdd43d8"
}
