#!/bin/bash

# Dynamically determine the directory of this script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Define the path to the stacks directory
STACKS_DIR="$SCRIPT_DIR/stacks"

# Export STACKS_DIR so terraform-runner.sh can use it
export STACKS_DIR

# Path to env.yaml
ENV_YAML="$SCRIPT_DIR/env.yaml"

# Source the terraform-runner.sh and local_setup.sh scripts
source "$SCRIPT_DIR/scripts/terraform-runner.sh"
source "$SCRIPT_DIR/scripts/local_setup.sh"

# Function to display usage/help
usage() {
  echo -e "${CYAN}Usage:${RESET} ./run.sh <stack_name> <team_name> <environment> <terraform_command> [--dry-run]"
  echo ""
  echo -e "${CYAN}Commands:${RESET}"
  echo -e "  ${GREEN}local_setup${RESET}  Validate that all required tools (e.g., Terraform, AWS CLI) are installed."
  echo -e "  ${GREEN}<stack_name> <team_name> <environment> <terraform_command>${RESET}  Run Terraform commands for a specific stack, team, and environment."
  echo ""
  echo -e "${CYAN}Options:${RESET}"
  echo -e "  ${YELLOW}--dry-run${RESET}  Show the commands that would be executed without running them."
  echo ""
  echo -e "${CYAN}Examples:${RESET}"
  echo -e "  ${BLUE}./run.sh local_setup${RESET}"
  echo -e "  ${BLUE}./run.sh stack_1 team1 dev init${RESET}"
  echo -e "  ${BLUE}./run.sh stack_1 team1 prod plan --dry-run${RESET}"
  echo -e "  ${BLUE}./run.sh stack_1 team2 qa apply${RESET}"
  echo -e "  ${BLUE}./run.sh stack_1 team3 dev destroy${RESET}"
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
    # Run local setup without requiring additional arguments
    validate_tools
    ;;
  *)
    # Validate that enough arguments are provided for other commands
    if [ "$#" -lt 3 ]; then
      echo -e "${RED}[ERROR]${RESET} Missing required arguments."
      usage
    fi

    STACK=$COMMAND
    TEAM=$1
    ENV=$2
    COMMAND=$3
    DRY_RUN=$4

    # Ensure env.yaml exists
    if [ ! -f "$ENV_YAML" ]; then
      echo -e "${RED}[ERROR]${RESET} Configuration file '${YELLOW}env.yaml${RESET}' not found in ${YELLOW}$SCRIPT_DIR${RESET}."
      exit 1
    fi

    validate_inputs "$STACKS_DIR"
    extract_backend_config "$TEAM" "$ENV"

    # Dispatch the Terraform command
    dispatch_command
    ;;
esac