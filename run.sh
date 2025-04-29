#!/bin/bash

# Dynamically determine the directory of this script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Define the path to the stacks directory
STACKS_DIR="$SCRIPT_DIR/stacks"

# Export STACKS_DIR so terraform-runner.sh can use it
export STACKS_DIR

# Source the terraform-runner.sh script using the absolute path
source "$SCRIPT_DIR/scripts/terraform-runner.sh"

# Function to display usage/help
usage() {
  echo -e "${CYAN}Usage:${RESET} ./run.sh <stack_name> <terraform_command> <environment> [--dry-run]"
  echo ""
  echo -e "${CYAN}Commands:${RESET}"
  echo -e "  ${GREEN}init${RESET}       Initialize the Terraform backend for the specified environment."
  echo -e "  ${GREEN}plan${RESET}       Generate and show an execution plan."
  echo -e "  ${GREEN}apply${RESET}      Apply the changes required to reach the desired state."
  echo -e "  ${GREEN}destroy${RESET}    Destroy the Terraform-managed infrastructure."
  echo -e "  ${GREEN}validate${RESET}   Validate the Terraform configuration files."
  echo ""
  echo -e "${CYAN}Options:${RESET}"
  echo -e "  ${YELLOW}--dry-run${RESET}  Show the commands that would be executed without running them."
  echo ""
  echo -e "${CYAN}Examples:${RESET}"
  echo -e "  ${BLUE}./run.sh stack_1 init dev${RESET}"
  echo -e "  ${BLUE}./run.sh stack_1 plan prod --dry-run${RESET}"
  echo -e "  ${BLUE}./run.sh stack_1 apply qa${RESET}"
  echo -e "  ${BLUE}./run.sh stack_1 destroy dev${RESET}"
  exit 0
}

# Validate inputs and execute commands
if [ "$#" -lt 3 ]; then
  echo -e "${RED}[ERROR]${RESET} Missing required arguments."
  usage
fi

STACK=$1
COMMAND=$2
ENV=$3
DRY_RUN=$4

validate_inputs "$STACKS_DIR"
extract_backend_config "$STACKS_DIR"

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo -e "${CYAN}[INFO]${RESET} Running in dry-run mode..."
  dry_run
else
  echo -e "${CYAN}[INFO]${RESET} Executing Terraform command..."
  execute_command
fi