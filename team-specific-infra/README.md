# Terraform Infrastructure Project

This project sets up a basic infrastructure using Terraform, demonstrating the use of modules for reusable components. The infrastructure includes an EC2 instance and an S3 bucket.

## Project Structure

```
terraform-infra-project
├── modules
│   ├── ec2          # Module for creating EC2 instances
│   ├── s3           # Module for creating S3 buckets
├── scripts
│   └── setup.sh     # Script for initializing the Terraform project
├── stacks
│   └── stack_1      # Stack configuration for deploying the infrastructure
├── README.md        # Project documentation
└── terraform.tfvars # Variable definitions for Terraform
```

## Getting Started

### Prerequisites

- Terraform installed on your machine.
- AWS account with appropriate permissions.
- AWS CLI configured with credentials.

### Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd terraform-infra-project
   ```

2. Initialize the Terraform project:
   ```
   ./scripts/setup.sh
   ```

3. Configure your `terraform.tfvars` file with the necessary variable values.

4. Deploy the infrastructure:
   ```
   terraform init
   terraform apply
   ```

### Modules

- **EC2 Module**: Located in `modules/ec2`, this module defines the configuration for creating an EC2 instance.
- **S3 Module**: Located in `modules/s3`, this module defines the configuration for creating an S3 bucket.

### Stacks

- **Stack 1**: Located in `stacks/stack_1`, this stack utilizes the EC2 and S3 modules to create the infrastructure.

### Outputs

After deployment, you can retrieve the outputs defined in the modules to get information such as instance IDs and bucket names.

## License

This project is licensed under the MIT License.