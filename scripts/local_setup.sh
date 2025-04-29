#!/bin/bash

# Define required versions
REQUIRED_TERRAFORM_VERSION="1.5.0"
REQUIRED_AWS_CLI_VERSION="2.12.0"

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
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
    success)
      echo -e "${GREEN}[SUCCESS]${RESET} $message"
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

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to compare versions
version_ge() {
  printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

# Check Terraform
check_terraform() {
  if command_exists terraform; then
    local terraform_version
    terraform_version=$(terraform version -json | jq -r '.terraform_version')
    if version_ge "$terraform_version" "$REQUIRED_TERRAFORM_VERSION"; then
      log success "Terraform version $terraform_version is installed and meets the requirement."
    else
      log error "Terraform version $terraform_version is installed but does not meet the required version $REQUIRED_TERRAFORM_VERSION."
      exit 1
    fi
  else
    log error "Terraform is not installed. Please install Terraform version $REQUIRED_TERRAFORM_VERSION or higher."
    exit 1
  fi
}

# Check AWS CLI
check_aws_cli() {
  if command_exists aws; then
    local aws_cli_version
    aws_cli_version=$(aws --version 2>&1 | awk '{print $1}' | cut -d/ -f2)
    if version_ge "$aws_cli_version" "$REQUIRED_AWS_CLI_VERSION"; then
      log success "AWS CLI version $aws_cli_version is installed and meets the requirement."
    else
      log error "AWS CLI version $aws_cli_version is installed but does not meet the required version $REQUIRED_AWS_CLI_VERSION."
      exit 1
    fi
  else
    log error "AWS CLI is not installed. Please install AWS CLI version $REQUIRED_AWS_CLI_VERSION or higher."
    exit 1
  fi
}

# Function to validate required tools
validate_tools() {
  log info "Validating required tools..."
  check_terraform
  check_aws_cli
  log success "All required tools are installed and meet the version requirements."
}