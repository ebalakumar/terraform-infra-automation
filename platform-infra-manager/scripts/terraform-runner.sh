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

# Function to extract backend configuration and app variables from team Pkl files
extract_backend_config() {
  local team=$1
  local env=$2
  local pkl_file="$STACKS_DIR/../config/teams/${team}.pkl"

  # Check if the team's Pkl file exists
  if [ ! -f "$pkl_file" ]; then
    log error "Team configuration file not found: ${pkl_file}"
    log info "Available team configurations:"
    ls "$STACKS_DIR/../config/teams/" 2>/dev/null | grep '\.pkl$' | sed 's/\.pkl$//' || log warn "No team configurations found."
    exit 1
  fi

  # First, check if the environment exists by trying to access it
  local env_check
  env_check=$(pkl eval "$pkl_file" -x "${env}" 2>/dev/null)
  
  if [ -z "$env_check" ]; then
    log error "Environment '${env}' not found in team configuration for '${team}'."
    log info "Available environments for team '${team}':"
    # Extract available environments using pure Pkl commands
    # Try each standard environment and see which ones exist
    for potential_env in dev qa prod; do
      if pkl eval "$pkl_file" -x "$potential_env" >/dev/null 2>&1; then
        echo "  $potential_env"
      fi
    done
    exit 1
  fi

  # Extract backend configuration using pkl eval
  BACKEND_REGION=$(pkl eval "$pkl_file" -x "commonBackendConfig.region" 2>/dev/null)
  BACKEND_BUCKET=$(pkl eval "$pkl_file" -x "${env}.bucket" 2>/dev/null)
  BACKEND_KEY="terraform.tfstate"  # Static key as defined in base.pkl

  # Extract app configuration variables using pkl eval
  INSTANCE_TYPE=$(pkl eval "$pkl_file" -x "${env}.instanceType" 2>/dev/null)
  AMI_ID=$(pkl eval "$pkl_file" -x "${env}.amiId" 2>/dev/null)
  KEY_NAME=$(pkl eval "$pkl_file" -x "${env}.keyName" 2>/dev/null)

  # Validate extracted values (this should not happen if environment check passed)
  if [ -z "$BACKEND_BUCKET" ] || [ -z "$BACKEND_REGION" ] || [ -z "$BACKEND_KEY" ]; then
    log error "Backend configuration is incomplete for team '${team}' and environment '${env}'."
    log error "This may indicate a configuration schema issue."
    exit 1
  fi

  if [ -z "$INSTANCE_TYPE" ] || [ -z "$AMI_ID" ] || [ -z "$KEY_NAME" ]; then
    log error "App configuration is incomplete for team '${team}' and environment '${env}'."
    log error "This may indicate a configuration schema issue."
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

    # Construct variable arguments from extracted Pkl values
    VAR_ARGS="--var instance_type=$INSTANCE_TYPE --var ami_id=$AMI_ID --var key_name=$KEY_NAME --var region=$BACKEND_REGION"
    execute_or_dry_run $dry_run "plan" "$VAR_ARGS"
    ;;
  apply)
    log info "Running 'terraform init' before 'terraform apply'..."
    execute_or_dry_run $dry_run "init" "-backend-config=\"bucket=$BACKEND_BUCKET\" -backend-config=\"key=$BACKEND_KEY\" -backend-config=\"region=$BACKEND_REGION\""

    # Construct variable arguments from extracted Pkl values
    VAR_ARGS="--var instance_type=$INSTANCE_TYPE --var ami_id=$AMI_ID --var key_name=$KEY_NAME --var region=$BACKEND_REGION"
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
