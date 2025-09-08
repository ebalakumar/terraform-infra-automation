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
    exit 1
  fi

  if [ "$DRY_RUN" != "" ] && [ "$DRY_RUN" != "--dry-run" ]; then
    log error "Invalid option '${DRY_RUN}'. The only supported option is '--dry-run'."
    exit 1
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

run_terraform_command() {
  local command=$1
  local args=$2

  # Construct the full Terraform command
  local full_command="terraform $command $args"

  if [ "$DRY_RUN" == "--dry-run" ]; then
    # Print the command instead of executing it
    log info "Dry-run mode enabled. The following command would be executed:"
    echo -e "${BLUE}$full_command${RESET}"
  else
    # Execute the command
    log info "Executing: $full_command"
    eval "$full_command"
  fi
}

# Function to execute Terraform commands
execute_command() {
  case $COMMAND in
    init)
      run_terraform_command "init" "-backend-config=\"bucket=$BACKEND_BUCKET\" -backend-config=\"key=$BACKEND_KEY\" -backend-config=\"region=$BACKEND_REGION\""
      ;;
    plan)
      run_terraform_command "plan" "-var-file=\"$VAR_FILE\""
      ;;
    apply)
      run_terraform_command "apply" "-var-file=\"$VAR_FILE\""
      ;;
    destroy)
      run_terraform_command "destroy" "-var-file=\"$VAR_FILE\""
      ;;
    validate)
      run_terraform_command "validate" ""
      ;;
    *)
      log error "Invalid command. Supported commands are: init, plan, apply, destroy, validate."
      exit 1
      ;;
  esac
}

# Function to validate inputs
validate_inputs() {
  local stack=$1
  local env=$2
  local command=$3
  local dry_run=$4

  if [ -z "$stack" ] || [ -z "$env" ] || [ -z "$command" ]; then
    log error "Missing required arguments. Please provide stack, env, and command."
    exit 1
  fi

  if [ "$dry_run" != false ] && [ "$dry_run" != true ]; then
    log error "Invalid value for dry-run. Use 'dry-run' or omit it."
    exit 1
  fi

  # Use STACKS_DIR from the environment variable
  STACK_PATH="$STACKS_DIR/$stack"

  # Check if the stack directory exists
  if [ ! -d "$STACK_PATH" ]; then
    log error "Stack '${YELLOW}$stack${RESET}' not found at ${YELLOW}$STACKS_DIR${RESET}"
    log info "Available stacks:"
    ls "$STACKS_DIR" 2>/dev/null || log warn "No stacks found in '$STACKS_DIR'."
    exit 1
  fi
}

# Function to extract backend configuration
extract_backend_config() {
  BACKEND_BUCKET=$(grep 'backend_bucket' "$STACK_PATH/$ENV.tfvars" | awk -F'=' '{print $2}' | tr -d ' "')
  BACKEND_KEY=$(grep 'backend_key' "$STACK_PATH/$ENV.tfvars" | awk -F'=' '{print $2}' | tr -d ' "')
  BACKEND_REGION=$(grep 'backend_region' "$STACK_PATH/$ENV.tfvars" | awk -F'=' '{print $2}' | tr -d ' "')

  if [ -z "$BACKEND_BUCKET" ] || [ -z "$BACKEND_KEY" ] || [ -z "$BACKEND_REGION" ]; then
    log error "Backend configuration is missing in ${YELLOW}$STACK_PATH/$ENV.tfvars${RESET}"
    exit 1
  fi
}

# Function to execute or print commands based on dry-run flag
execute_or_dry_run() {
  local dry_run=$1
  local command=$2
  local args=$3
  # Construct the full Terraform command
  local full_command="terraform $command $args"

  # Log the command being executed or printed
  log info "Command to be executed: $full_command"

  if [ "$dry_run" == "true" ]; then
    # Print the command instead of executing it
    log info "Dry-run mode enabled. The following command would be executed:"
    echo -e "${BLUE}$full_command${RESET}"
  else
    log info "Executing: $full_command"
    eval "$full_command"
  fi
}

# Function to dispatch Terraform commands
dispatch_command() {
  local stack=$1
  local env=$2
  local command=$3
  local dry_run=$4

  validate_inputs "$stack" "$env" "$command" "$dry_run"
  extract_backend_config

  # Change to the stack directory
  cd "$STACK_PATH" || exit 1

  # Dispatch the Terraform command
  case $command in
    init)
      execute_or_dry_run $dry_run "init" "-backend-config=\"bucket=$BACKEND_BUCKET\" -backend-config=\"key=$BACKEND_KEY\" -backend-config=\"region=$BACKEND_REGION\""
      ;;
    plan)
      log info "Running 'terraform init' before 'terraform plan'..."
      execute_or_dry_run $dry_run "init" "-backend-config=\"bucket=$BACKEND_BUCKET\" -backend-config=\"key=$BACKEND_KEY\" -backend-config=\"region=$BACKEND_REGION\""
      execute_or_dry_run $dry_run "plan" "-var-file=$ENV.tfvars"
      ;;
    apply)
      log info "Running 'terraform init' before 'terraform apply'..."      
      execute_or_dry_run $dry_run "init" "-backend-config=\"bucket=$BACKEND_BUCKET\" -backend-config=\"key=$BACKEND_KEY\" -backend-config=\"region=$BACKEND_REGION\""
      execute_or_dry_run $dry_run "apply" "-var-file=$ENV.tfvars"
      ;;
    destroy)
      log info "Running 'terraform init' before 'terraform destroy'..."
      execute_or_dry_run $dry_run "init" "-backend-config=\"bucket=$BACKEND_BUCKET\" -backend-config=\"key=$BACKEND_KEY\" -backend-config=\"region=$BACKEND_REGION\""
      execute_or_dry_run $dry_run "destroy" "-var-file=$ENV.tfvars"
      ;;
    validate)
      execute_or_dry_run $dry_run "validate" ""
      ;;
    *)
      log error "Invalid command. Supported commands are: init, plan, apply, destroy, validate."
      exit 1
      ;;
  esac
}