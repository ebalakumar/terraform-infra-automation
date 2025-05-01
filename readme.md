# Terraform Infra Automation

This repository provides a framework for automating infrastructure provisioning and management using Terraform. It is designed to support both **team-specific infrastructure** and **platform-wide infrastructure** needs, enabling modular, scalable, and environment-specific configurations.

---

## Repository Structure

The repository is divided into two main components:

### 1. **Team-Specific Infra**
Located in the team-specific-infra directory, this component is tailored for individual teams to manage their specific infrastructure needs. Key features include:
- **Stacks**: Environment-specific configurations for each team.
- **Modules**: Reusable Terraform modules for common infrastructure components.
- **Scripts**: Automation scripts for running Terraform commands.

Refer to the Team-Specific Infra Readme for more details.

### 2. **Platform Infra Manager**
Located in the platform-infra-manager directory, this component is designed for platform teams to manage infrastructure across multiple teams. Key features include:
- **Centralized Configuration**: Team-specific and environment-specific configurations managed via `env.yaml`.
- **Reusable Modules**: Shared Terraform modules for platform-wide infrastructure.
- **Automation Scripts**: Scripts to streamline Terraform operations for multiple teams.

Refer to the Platform Infra Manager Readme for more details.

---

## Key Features

- **Modular Design**: Reusable Terraform modules for common infrastructure components like EC2 instances and S3 buckets.
- **Environment-Specific Configurations**: Manage infrastructure for `dev`, `qa`, `prod`, and other environments using `.tfvars` files or `env.yaml`.
- **Automation**: Scripts simplify Terraform operations, reducing manual effort and ensuring consistency.
- **Partial Remote Backend Configuration**: Ensures each environment has its own remote backend, minimizing the blast radius of potential issues.
- **Team and Platform Focused**: Supports both individual team needs and platform-wide infrastructure management.

---

## Usage

### 1. **Set Up Environment**
- For **team-specific infra**, update the `.tfvars` files in the stacks directory with environment-specific configurations.
- For **platform infra manager**, update the `env.yaml` file in the platform-infra-manager directory with team-specific and environment-specific configurations.

### 2. **Run Scripts**
- Use the run.sh script in either team-specific-infra or platform-infra-manager to execute Terraform commands. The script automates operations like `init`, `plan`, `apply`, `destroy`, and `validate`.

### 3. **Local Setup**
- Run the `local_setup.sh` script in the respective directory to prepare your local environment for Terraform operations.

---

## Examples

### Team-Specific Infra
```bash
# Initialize Terraform for a specific stack and environment
./team-specific-infra/run.sh stack=stack_1 team=team1 env=dev command=init

# Plan changes for a specific stack and environment
./team-specific-infra/run.sh stack=stack_1 team=team1 env=prod command=plan dry-run
```

### Platform Infra Manager
```bash
# Initialize Terraform for a specific stack and environment
./platform-infra-manager/run.sh stack=stack_1 team=team1 env=dev command=init

# Apply changes for a specific stack and environment
./platform-infra-manager/run.sh stack=stack_1 team=team2 env=qa command=apply
```

---

## References

- [Infrastructure as Code - Chapter 5](https://www.oreilly.com/library/view/infrastructure-as-code/9781098114664/ch05.html)
- [Terraform Partial Backend Configuration](https://developer.hashicorp.com/terraform/language/backend#partial-configuration)

---

This repository is designed to simplify and standardize infrastructure management for both individual teams and platform-wide operations. For more details, refer to the respective readme files in the team-specific-infra and platform-infra-manager directories.