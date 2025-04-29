# Backend configuration
backend_bucket = "my-terraform-state-dev"
backend_key    = "stack_1/terraform.tfstate"
backend_region = "us-east-1"

# Resource-specific variables
environment   = "dev"
bucket_name   = "my-dev-bucket"
instance_type = "t3.micro"
ami_id        = "ami-12345678"
key_name      = "dev-key"