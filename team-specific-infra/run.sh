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
  echo -e "${CYAN}Usage:${RESET} ./run.sh stack=<stack_name> team=<team_name> env=<environment> command=<terraform_command> [dry-run]"
  echo ""
  echo -e "${CYAN}Commands:${RESET}"
  echo -e "  ${GREEN}local_setup${RESET}  Validate that all required tools (e.g., Terraform, AWS CLI) are installed."
  echo -e "  ${GREEN}stack=<stack_name> team=<team_name> env=<environment> command=<terraform_command>${RESET}  Run Terraform commands for a specific stack, team, and environment."
  echo ""
  echo -e "${CYAN}Options:${RESET}"
  echo -e "  ${YELLOW}dry-run${RESET}  Show the commands that would be executed without running them."
  echo ""
  echo -e "${CYAN}Examples:${RESET}"
  echo -e "  ${BLUE}./run.sh local_setup${RESET}"
  echo -e "  ${BLUE}./run.sh stack=stack_1 team=team1 env=dev command=init${RESET}"
  echo -e "  ${BLUE}./run.sh stack=stack_1 team=team1 env=prod command=plan dry-run${RESET}"
  echo -e "  ${BLUE}./run.sh stack=stack_1 team=team2 env=qa command=apply${RESET}"
  echo -e "  ${BLUE}./run.sh stack=stack_1 team=team3 env=dev command=destroy${RESET}"
  exit 0
}

# Parse named parameters
STACK=""
TEAM=""
ENV=""
COMMAND=""
DRY_RUN=false

for arg in "$@"; do
  case $arg in
    stack=*)
      STACK="${arg#*=}"
      ;;
    team=*)
      TEAM="${arg#*=}"
      ;;
    env=*)
      ENV="${arg#*=}"
      ;;
    command=*)
      COMMAND="${arg#*=}"
      ;;
    dry-run)
      DRY_RUN=true
      ;;
    *)
      echo -e "${RED}[ERROR]${RESET} Unknown argument: $arg"
      usage
      ;;
  esac
done

# Validate mandatory parameters
if [ -z "$STACK" ] || [ -z "$TEAM" ] || [ -z "$ENV" ] || [ -z "$COMMAND" ]; then
  echo -e "${RED}[ERROR]${RESET} Missing required arguments."
  usage
fi

# Dispatch the Terraform command
dispatch_command "$STACK" "$TEAM" "$ENV" "$COMMAND" "$DRY_RUN"