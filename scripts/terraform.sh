#!/bin/bash

STACK=$1
COMMAND=$2
ENV=$3
DRY_RUN=$4

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Function to display usage/help
usage() {
  echo -e "${CYAN}Usage:${RESET} ./terraform.sh <stack_name> <terraform_command> <environment> [--dry-run]"
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
  echo -e "  ${BLUE}./terraform.sh stack_1 init dev${RESET}"
  echo -e "  ${BLUE}./terraform.sh stack_1 plan prod --dry-run${RESET}"
  echo -e "  ${BLUE}./terraform.sh stack_1 apply qa${RESET}"
  echo -e "  ${BLUE}./terraform.sh stack_1 destroy dev${RESET}"
  exit 0
}

# Function to log messages
log() {
  local type=$1
  local message=$2
  case $type in
    info)
      echo -e "${CYAN}[INFO]${RESET} $message"
      ;;
    warn)
      echo -e "${YELLOW}[WARN]${RESET} $message"
      ;;
    error)
      echo -e "${RED}[ERROR]${RESET} $message"
      ;;
    *)
      echo -e "$message"
      ;;
  esac
}

validate_inputs() {
  if [ -z "$STACK" ] || [ -z "$COMMAND" ] || [ -z "$ENV" ]; then
    log error "Missing required arguments. Please provide <stack_name>, <terraform_command>, and <environment>."
    usage
  fi

  if [ "$DRY_RUN" != "" ] && [ "$DRY_RUN" != "--dry-run" ]; then
    log error "Invalid option '${DRY_RUN}'. The only supported option is '--dry-run'."
    usage
  fi

  # Use STACKS_DIR from the environment variable
  STACK_PATH="$STACKS_DIR/$STACK"
  VAR_FILE="$STACK_PATH/$ENV.tfvars"

  # Check if the stack directory exists
  if [ ! -d "$STACK_PATH" ]; then
    log error "Stack '${YELLOW}$STACK${RESET}' not found at ${YELLOW}$STACKS_DIR${RESET}"
    log info "Available stacks:"
    ls "$STACKS_DIR" 2>/dev/null || log warn "No stacks found in '$STACKS_DIR'."
    exit 1
  fi

  # Check if the variable file exists
  if [ ! -f "$VAR_FILE" ]; then
    log error "Variable file for environment '${YELLOW}$ENV${RESET}' not found at ${YELLOW}$VAR_FILE${RESET}."
    log info "Please create the file with the required variables or verify the environment name."
    log info "Example: touch ${VAR_FILE}"
    exit 1
  fi
}

# Function to extract backend configuration
extract_backend_config() {
  BACKEND_BUCKET=$(grep 'backend_bucket' "$VAR_FILE" | awk -F'=' '{print $2}' | tr -d ' "')
  BACKEND_KEY=$(grep 'backend_key' "$VAR_FILE" | awk -F'=' '{print $2}' | tr -d ' "')
  BACKEND_REGION=$(grep 'backend_region' "$VAR_FILE" | awk -F'=' '{print $2}' | tr -d ' "')

  if [ -z "$BACKEND_BUCKET" ] || [ -z "$BACKEND_KEY" ] || [ -z "$BACKEND_REGION" ]; then
    log error "Backend configuration is missing in ${YELLOW}$VAR_FILE${RESET}"
    exit 1
  fi
}

# Function to initialize Terraform backend
terraform_init() {
  terraform init \
    -backend-config="bucket=$BACKEND_BUCKET" \
    -backend-config="key=$BACKEND_KEY" \
    -backend-config="region=$BACKEND_REGION"
}

# Function to handle dry-run mode
dry_run() {
  log info "Dry-run mode enabled. The following commands would be executed:"
  case $COMMAND in
    init)
      echo -e "${BLUE}terraform init -backend-config=\"bucket=$BACKEND_BUCKET\" -backend-config=\"key=$BACKEND_KEY\" -backend-config=\"region=$BACKEND_REGION\"${RESET}"
      ;;
    plan)
      echo -e "${BLUE}terraform plan -var-file=\"$VAR_FILE\"${RESET}"
      ;;
    apply)
      echo -e "${BLUE}terraform apply -var-file=\"$VAR_FILE\"${RESET}"
      ;;
    destroy)
      echo -e "${BLUE}terraform destroy -var-file=\"$VAR_FILE\"${RESET}"
      ;;
    validate)
      echo -e "${BLUE}terraform validate${RESET}"
      ;;
    *)
      log error "Invalid command. Supported commands are: init, plan, apply, destroy, validate."
      exit 1
      ;;
  esac
  exit 0
}

# Function to execute Terraform commands
execute_command() {
  case $COMMAND in
    init)
      terraform_init
      ;;
    plan)
      terraform_init
      terraform plan -var-file="$VAR_FILE"
      ;;
    apply)
      terraform_init
      terraform apply -var-file="$VAR_FILE"
      ;;
    destroy)
      terraform_init
      terraform destroy -var-file="$VAR_FILE"
      ;;
    validate)
      terraform validate
      ;;
    *)
      log error "Invalid command. Supported commands are: init, plan, apply, destroy, validate."
      exit 1
      ;;
  esac
}