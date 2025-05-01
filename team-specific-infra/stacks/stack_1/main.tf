terraform {
  backend "s3" {}
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }
}

module "ec2_instance" {
  source        = "../../modules/ec2"
  instance_type = var.instance_type
  ami_id        = var.ami_id
  key_name      = var.key_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

output "ec2_instance_id" {
  value = module.ec2_instance.instance_id
}

output "ec2_public_ip" {
  value = module.ec2_instance.public_ip
}