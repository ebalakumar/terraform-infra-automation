variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to create"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "The key name for the EC2 instance"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}