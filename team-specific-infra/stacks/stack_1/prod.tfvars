# Backend configuration
backend_bucket = "my-terraform-state-prod"
backend_key    = "stack_1/terraform.tfstate"
backend_region = "us-east-1"

# Resource-specific variables
environment   = "prod"
bucket_name   = "my-prod-bucket"
instance_type = "t3.large"
ami_id        = "ami-87654321"
key_name      = "prod-key"