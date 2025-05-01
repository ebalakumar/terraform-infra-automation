# Team-Specific Infra

The **Team-Specific Infra** repository is a Terraform-based project designed to help individual teams provision and manage their specific infrastructure needs. It follows the infrastructure stack model as described in [Infrastructure as Code](https://www.oreilly.com/library/view/infrastructure-as-code/9781098114664/ch05.html) and uses partial remote backend configuration when initializing Terraform modules. Learn more about partial configuration [here](https://developer.hashicorp.com/terraform/language/backend#partial-configuration).

---

## Repository Structure

The repository is organized into the following components:

### 1. Stacks
A **stack** is a collection of infrastructure resources that are defined and managed together. Stacks are located in the `stacks/` directory and represent specific configurations for different environments (e.g., `dev`, `qa`, `prod`).

### 2. Modules
**Modules** are reusable Terraform configurations that define specific infrastructure components (e.g., EC2 instances, S3 buckets). These are located in the `modules/` directory and can be shared across stacks:
- `ec2/`: Defines EC2 instance configurations.
- `s3/`: Defines S3 bucket configurations.

### 3. Scripts
**Scripts** automate the provisioning and management of stacks. The following scripts are included:
- **`run.sh`**: Main script to execute Terraform operations on stacks.
- **`local_setup.sh`**: Sets up the local environment for Terraform operations.
- **`terraform-runner.sh`**: Helper script to streamline Terraform commands.

### 4. Configuration
- **`.tfvars` files**: Contain environment-specific configurations for each stack.

---

## Key Features

- **Modular Design**: Reusable modules for common infrastructure components like EC2 and S3.
- **Environment-Specific Configurations**: Manage infrastructure for `dev`, `qa`, and `prod` environments using stack-specific `.tfvars` files.
- **Automation**: Scripts simplify Terraform operations, reducing manual effort.
- **Partial Remote Backend Configuration**: Ensures each environment has its own remote backend, minimizing the impact of potential issues and reducing the blast radius.
- **Team-Focused**: Tailored for individual team infrastructure needs.

---

## Usage

1. **Set Up Environment**:
   - Update the `.tfvars` files in the `stacks/` directory with environment-specific configurations.

2. **Run Scripts**:
   - Use the `run.sh` script to provision or manage stacks. The script automates Terraform commands for the specified stack and environment.

3. **Local Setup**:
   - Run `local_setup.sh` to prepare your local environment for Terraform operations.

---

## References

- [Infrastructure as Code - Chapter 5](https://www.oreilly.com/library/view/infrastructure-as-code/9781098114664/ch05.html)
- [Terraform Partial Backend Configuration](https://developer.hashicorp.com/terraform/language/backend#partial-configuration)