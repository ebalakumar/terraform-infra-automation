# Platform Infra Manager

The **Platform Infra Manager** is a Terraform-based repository designed to help platform teams provision and manage infrastructure for multiple teams. It follows the infrastructure stack model as described in [Infrastructure as Code](https://www.oreilly.com/library/view/infrastructure-as-code/9781098114664/ch05.html) and uses partial remote backend configuration when initializing Terraform modules. Learn more about partial configuration [here](https://developer.hashicorp.com/terraform/language/backend#partial-configuration).

---

## Repository Structure

The repository is organized into the following components:

### 1. Stacks
A **stack** is a collection of infrastructure resources that are defined and managed together. Stacks are located in the `stacks/` directory and represent specific infrastructure configurations.

### 2. Modules
**Modules** are reusable Terraform configurations that define specific infrastructure components (e.g., EC2 instances, S3 buckets). These are located in the `modules/` directory and can be shared across stacks.

**Scripts** automate the provisioning and management of stacks. The following scripts are included:
- **`run.sh`**: Main script to execute Terraform operations on stacks.
- **`local_setup.sh`**: Sets up the local environment for Terraform operations.
- **`terraform-runner.sh`**: Helper script to streamline Terraform commands.

### 4. Configuration
- **`env.yaml`**: Contains team-specific configurations and environment details.

---

## Key Features

- **Modular Design**: Reusable modules for common infrastructure components.
- **Stack-Based Management**: Simplifies infrastructure changes by grouping resources into stacks.
- **Automation**: Scripts streamline Terraform operations, reducing manual effort.
- **Team-Specific Configurations**: Easily manage infrastructure for multiple teams using `env.yaml`.
- **Partial Remote Backend Configuration**: Ensures each environment for every team has its own remote backend, minimizing the impact of potential issues and reducing the blast radius.

---

## Usage

1. **Set Up Environment**:
   - Update the `env.yaml` file with your team-specific configurations and environment details.

2. **Run Scripts**:
   - Use the `run.sh` script to provision or manage stacks. The script automates Terraform commands based on the configurations in `env.yaml`.

---

## References

- [Infrastructure as Code - Chapter 5](https://www.oreilly.com/library/view/infrastructure-as-code/9781098114664/ch05.html)
- [Terraform Partial Backend Configuration](https://developer.hashicorp.com/terraform/language/backend#partial-configuration)