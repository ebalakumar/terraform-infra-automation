#!/bin/bash

# Dynamically determine the directory of this script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Define the path to the stacks directory
STACKS_DIR="$SCRIPT_DIR/stacks"

# Export STACKS_DIR so terraform.sh can use it
export STACKS_DIR

# Source the terraform.sh script using the absolute path
source "$SCRIPT_DIR/scripts/terraform.sh"

# Call functions from terraform.sh
validate_inputs "$STACKS_DIR"
extract_backend_config "$STACKS_DIR"

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo -e "${CYAN}[INFO]${RESET} Running in dry-run mode..."
  dry_run
else
  echo -e "${CYAN}[INFO]${RESET} Executing Terraform command..."
  execute_command
fi