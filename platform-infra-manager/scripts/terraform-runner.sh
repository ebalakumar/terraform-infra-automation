#!/bin/bash
set +x

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

# Function to validate inputs
validate_inputs() {
  local stack=$1
  local team=$2
  local env=$3
  local command=$4
  local dry_run=$5

  if [ -z "$stack" ] || [ -z "$team" ] || [ -z "$env" ] || [ -z "$command" ]; then
    log error "Missing required arguments. Please provide stack, team, env, and command."
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

# Function to extract backend configuration and app variables from env.yaml
extract_backend_config() {
  local yaml_file="$STACKS_DIR/../env.yaml"
  local team=$1
  local env=$2

  # Extract backend configuration from common_backend_config
  BACKEND_REGION=$(yq '.common_backend_config.region' "$yaml_file")

  # Extract backend configuration from remote_backend for the specific team and environment
  REMOTE_BACKEND_BUCKET=$(yq ".stack_configs[] | select(.name == \"$team\") | .environment | .\"$env\".remote_backend.bucket" "$yaml_file")
  REMOTE_BACKEND_KEY=$(yq ".stack_configs[] | select(.name == \"$team\") | .environment | .\"$env\".remote_backend.key" "$yaml_file")

  # Combine backend configuration
  BACKEND_BUCKET=$REMOTE_BACKEND_BUCKET
  BACKEND_KEY=$REMOTE_BACKEND_KEY

  # Extract app configuration variables
  APP_CONFIG=$(yq ".stack_configs[] | select(.name == \"$team\") | .environment | .\"$env\".app_config" "$yaml_file")

  # Validate extracted values
  if [ -z "$BACKEND_BUCKET" ] || [ -z "$BACKEND_REGION" ] || [ -z "$BACKEND_KEY" ]; then
    log error "Backend configuration is missing for team '${team}' and environment '${env}' in ${yaml_file}."
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

  # Log the command being executed or printed with a different color
  MAGENTA='\033[0;35m'
  log info "${MAGENTA}Command to be executed:${RESET} $full_command"

  if [ "$dry_run" == "true" ]; then
    # Print the command instead of executing it
    log info "Dry-run mode enabled. The following command would be executed:"
    echo -e "${BLUE}$full_command${RESET}"
  else
    # Execute the command
    log info "Executing: $full_command"
    eval "$full_command"
  fi
}

# Function to dispatch Terraform commands
dispatch_command() {
  local stack=$1
  local team=$2
  local env=$3
  local command=$4
  local dry_run=$5

  validate_inputs "$stack" "$team" "$env" "$command" "$dry_run"

  # Extract backend configuration
  extract_backend_config "$team" "$env"

  # Change to the stack directory
  STACK_PATH="$STACKS_DIR/$stack"
  if [ ! -d "$STACK_PATH" ]; then
    log error "Stack directory '$STACK_PATH' does not exist."
    exit 1
  fi
  cd "$STACK_PATH" || exit 1

  # Dispatch the Terraform command
  case $command in
  init)
    execute_or_dry_run $dry_run "init" "-backend-config=\"bucket=$BACKEND_BUCKET\" -backend-config=\"key=$BACKEND_KEY\" -backend-config=\"region=$BACKEND_REGION\""
    ;;
  plan)
    log info "Running 'terraform init' before 'terraform plan'..."
    execute_or_dry_run $dry_run "init" "-backend-config=\"bucket=$BACKEND_BUCKET\" -backend-config=\"key=$BACKEND_KEY\" -backend-config=\"region=$BACKEND_REGION\""

    # Construct variable arguments from APP_CONFIG
    VAR_ARGS=$(echo "$APP_CONFIG" | yq 'to_entries | map("--var \(.key)=\(.value|tostring)") | join(" ")')
    execute_or_dry_run $dry_run "plan" "$VAR_ARGS" $dry_run
    ;;
  apply)
    log info "Running 'terraform init' before 'terraform apply'..."
    execute_or_dry_run $dry_run "init" "-backend-config=\"bucket=$BACKEND_BUCKET\" -backend-config=\"key=$BACKEND_KEY\" -backend-config=\"region=$BACKEND_REGION\""

    # Construct variable arguments from APP_CONFIG
    VAR_ARGS=$(echo "$APP_CONFIG" | yq 'to_entries | map("--var \(.key)=\(.value|tostring)") | join(" ")')
    execute_or_dry_run $dry_run "apply" "$VAR_ARGS"
    ;;
  destroy)
    log info "Running 'terraform init' before 'terraform destroy'..."
    execute_or_dry_run $dry_run "init" "-backend-config=\"bucket=$BACKEND_BUCKET\" -backend-config=\"key=$BACKEND_KEY\" -backend-config=\"region=$BACKEND_REGION\""
    execute_or_dry_run $dry_run "destroy" ""
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
