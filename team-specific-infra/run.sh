#!/bin/bash

# Dynamically determine the directory of this script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Define the path to the stacks directory
STACKS_DIR="$SCRIPT_DIR/stacks"

# Export STACKS_DIR so terraform-runner.sh can use it
export STACKS_DIR

# Source the terraform-runner.sh and local_setup.sh scripts
source "$SCRIPT_DIR/scripts/terraform-runner.sh"
source "$SCRIPT_DIR/scripts/local_setup.sh"

# Function to display usage/help
usage() {
  echo -e "${CYAN}Usage:${RESET} ./run.sh <command> [arguments]"
  echo ""
  echo -e "${CYAN}Commands:${RESET}"
  echo -e "  ${GREEN}local_setup${RESET}  Validate that all required tools (e.g., Terraform, AWS CLI) are installed."
  echo -e "  ${GREEN}<stack_name> <terraform_command> <environment>${RESET}  Run Terraform commands for a specific stack and environment."
  echo ""
  echo -e "${CYAN}Options:${RESET}"
  echo -e "  ${YELLOW}--dry-run${RESET}  Show the commands that would be executed without running them."
  echo ""
  echo -e "${CYAN}Examples:${RESET}"
  echo -e "  ${BLUE}./run.sh local_setup${RESET}"
  echo -e "  ${BLUE}./run.sh stack_1 init dev${RESET}"
  echo -e "  ${BLUE}./run.sh stack_1 plan prod --dry-run${RESET}"
  echo -e "  ${BLUE}./run.sh stack_1 apply qa${RESET}"
  echo -e "  ${BLUE}./run.sh stack_1 destroy dev${RESET}"
  exit 0
}

# Validate inputs and execute commands
if [ "$#" -lt 1 ]; then
  echo -e "${RED}[ERROR]${RESET} Missing required arguments."
  usage
fi

COMMAND=$1
shift

case $COMMAND in
  local_setup)
    validate_tools
    ;;
  *)
    STACK=$COMMAND
    COMMAND=$1
    ENV=$2
    DRY_RUN=$3
    validate_inputs "$STACKS_DIR"
    extract_backend_config "$STACKS_DIR"
    if [ "$DRY_RUN" == "--dry-run" ]; then
      echo -e "${CYAN}[INFO]${RESET} Running in dry-run mode..."
      dry_run
    else
      echo -e "${CYAN}[INFO]${RESET} Executing Terraform command..."
      execute_command
    fi
    ;;
esac