# Backend configuration
backend_bucket = "my-terraform-state-qa"
backend_key    = "stack_1/terraform.tfstate"
backend_region = "us-east-1"

# Resource-specific variables
environment   = "qa"
bucket_name   = "my-qa-bucket"
instance_type = "t3.medium"
ami_id        = "ami-11223344"
key_name      = "qa-key"