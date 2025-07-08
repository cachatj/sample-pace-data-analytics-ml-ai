#!/bin/bash
# Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# Healthcare Revenue Cycle Management - VHT Configuration Update Script
# This script updates generated component configurations with environment-specific values
# Following DAIVI IaC best practices for component configuration

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values for VHT Healthcare project
DEFAULT_APP_NAME="vhtds"
DEFAULT_ENV_NAME="dev"
DEFAULT_AWS_PRIMARY_REGION="us-east-1"
DEFAULT_AWS_SECONDARY_REGION="us-east-2"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to validate inputs
validate_inputs() {
    if [[ -z "$APP_NAME" ]]; then
        print_error "APP_NAME cannot be empty"
        exit 1
    fi
    
    if [[ -z "$ENV_NAME" ]]; then
        print_error "ENV_NAME cannot be empty"
        exit 1
    fi
    
    if [[ -z "$AWS_PRIMARY_REGION" ]]; then
        print_error "AWS_PRIMARY_REGION cannot be empty"
        exit 1
    fi
    
    if [[ -z "$AWS_SECONDARY_REGION" ]]; then
        print_error "AWS_SECONDARY_REGION cannot be empty"
        exit 1
    fi
    
    # Validate region format
    if [[ ! "$AWS_PRIMARY_REGION" =~ ^[a-z]{2}-[a-z]+-[0-9]$ ]]; then
        print_error "Invalid AWS_PRIMARY_REGION format: $AWS_PRIMARY_REGION"
        exit 1
    fi
    
    if [[ ! "$AWS_SECONDARY_REGION" =~ ^[a-z]{2}-[a-z]+-[0-9]$ ]]; then
        print_error "Invalid AWS_SECONDARY_REGION format: $AWS_SECONDARY_REGION"
        exit 1
    fi
}

# Function to get AWS Account ID
get_aws_account_id() {
    local account_id
    if command -v aws >/dev/null 2>&1; then
        account_id=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "")
        if [[ -n "$account_id" && "$account_id" =~ ^[0-9]{12}$ ]]; then
            echo "$account_id"
            return 0
        fi
    fi
    
    print_warning "Could not retrieve AWS Account ID automatically"
    read -p "Please enter your 12-digit AWS Account ID: " account_id
    
    if [[ ! "$account_id" =~ ^[0-9]{12}$ ]]; then
        print_error "Invalid AWS Account ID format: $account_id"
        exit 1
    fi
    
    echo "$account_id"
}

# Function to backup original files
backup_files() {
    local backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    print_status "Creating backup in $backup_dir"
    
    mkdir -p "$backup_dir"
    
    # Find and backup all tfvars and backend.tf files from generated components
    find iac/roots -name "*.tfvars" -o -name "backend.tf" | while read -r file; do
        if [[ -f "$file" ]]; then
            local backup_path="$backup_dir/$file"
            mkdir -p "$(dirname "$backup_path")"
            cp "$file" "$backup_path"
        fi
    done
    
    print_success "Backup completed in $backup_dir"
}

# Function to update files in a directory
update_directory() {
    local dir="$1"
    local files_updated=0
    
    if [[ ! -d "$dir" ]]; then
        print_warning "Directory not found: $dir"
        return 0
    fi
    
    print_status "Updating component files in $dir"
    
    # Update terraform.tfvars files
    while IFS= read -r -d '' file; do
        print_status "  Updating $(basename "$file")"
        
        # Use temporary file for safe replacement
        local temp_file
        temp_file=$(mktemp)
        
        sed \
            -e "s/###APP_NAME###/$APP_NAME/g" \
            -e "s/###ENV_NAME###/$ENV_NAME/g" \
            -e "s/###AWS_PRIMARY_REGION###/$AWS_PRIMARY_REGION/g" \
            -e "s/###AWS_SECONDARY_REGION###/$AWS_SECONDARY_REGION/g" \
            -e "s/###AWS_ACCOUNT_ID###/$AWS_ACCOUNT_ID/g" \
            "$file" > "$temp_file"
        
        # Only update if the file actually changed
        if ! diff -q "$file" "$temp_file" >/dev/null 2>&1; then
            mv "$temp_file" "$file"
            files_updated=$((files_updated + 1))
        else
            rm "$temp_file"
        fi
    done < <(find "$dir" -name "*.tfvars" -type f -print0)
    
    # Update backend.tf files
    while IFS= read -r -d '' file; do
        print_status "  Updating $(basename "$file")"
        
        # Use temporary file for safe replacement
        local temp_file
        temp_file=$(mktemp)
        
        sed \
            -e "s/###APP_NAME###/$APP_NAME/g" \
            -e "s/###ENV_NAME###/$ENV_NAME/g" \
            -e "s/###AWS_PRIMARY_REGION###/$AWS_PRIMARY_REGION/g" \
            -e "s/###AWS_SECONDARY_REGION###/$AWS_SECONDARY_REGION/g" \
            -e "s/###AWS_ACCOUNT_ID###/$AWS_ACCOUNT_ID/g" \
            "$file" > "$temp_file"
        
        # Only update if the file actually changed
        if ! diff -q "$file" "$temp_file" >/dev/null 2>&1; then
            mv "$temp_file" "$file"
            files_updated=$((files_updated + 1))
        else
            rm "$temp_file"
        fi
    done < <(find "$dir" -name "backend.tf" -type f -print0)
    
    if [[ $files_updated -gt 0 ]]; then
        print_success "  Updated $files_updated files in $dir"
    else
        print_status "  No files needed updating in $dir"
    fi
    
    return $files_updated
}

# Function to verify updates
verify_updates() {
    print_status "Verifying component configuration updates..."
    
    local verification_failed=0
    
    # Check for any remaining placeholders in generated components
    while IFS= read -r -d '' file; do
        if grep -q "###.*###" "$file"; then
            print_error "Placeholders still found in $file:"
            grep "###.*###" "$file" | head -5
            verification_failed=1
        fi
    done < <(find iac/roots -name "*.tfvars" -o -name "backend.tf" -type f -print0)
    
    if [[ $verification_failed -eq 1 ]]; then
        print_error "Verification failed! Some placeholders were not replaced."
        exit 1
    fi
    
    print_success "Verification completed successfully"
}

# Function to display summary
display_summary() {
    print_success "Component configuration update completed!"
    echo
    echo "📋 Configuration Summary:"
    echo "  App Name:           $APP_NAME"
    echo "  Environment:        $ENV_NAME"
    echo "  AWS Account ID:     $AWS_ACCOUNT_ID"
    echo "  Primary Region:     $AWS_PRIMARY_REGION"
    echo "  Secondary Region:   $AWS_SECONDARY_REGION"
    echo
    echo "🔧 Next Steps (following DAIVI IaC best practices):"
    echo "  1. Review the updated component configurations"
    echo "  2. Add deployment targets to Makefile for each component:"
    echo "     - deploy-vht-payer-propensity-producer"
    echo "     - deploy-vht-claims-denial-mgmt-producer" 
    echo "     - deploy-vht-rag-chat-producer"
    echo "     - deploy-vht-analytics-consumer"
    echo "  3. Deploy components manually using standard DAIVI patterns:"
    echo "     cd iac/roots/sagemaker/[project-name]"
    echo "     terraform init && terraform apply"
    echo "  4. Follow DAIVI deployment order and dependencies"
    echo
}

# Main execution
main() {
    echo "🏥 VHT Healthcare Revenue Cycle Management - Component Configuration Update"
    echo "=========================================================================="
    echo "This script updates generated DAIVI component configurations"
    echo
    
    # Check if we're in the right directory
    if [[ ! -f "vht_daivi_project_generator.py" ]]; then
        print_error "Please run this script from the DAIVI root directory"
        exit 1
    fi
    
    # Get configuration values
    print_status "Getting configuration values..."
    
    # Use provided values or defaults
    APP_NAME="${1:-$DEFAULT_APP_NAME}"
    ENV_NAME="${2:-$DEFAULT_ENV_NAME}"
    AWS_PRIMARY_REGION="${3:-$DEFAULT_AWS_PRIMARY_REGION}"
    AWS_SECONDARY_REGION="${4:-$DEFAULT_AWS_SECONDARY_REGION}"
    
    # Interactive mode if no parameters provided
    if [[ $# -eq 0 ]]; then
        echo "Enter configuration values (press Enter for defaults):"
        echo
        
        read -p "App Name [$DEFAULT_APP_NAME]: " input_app_name
        APP_NAME="${input_app_name:-$DEFAULT_APP_NAME}"
        
        read -p "Environment Name [$DEFAULT_ENV_NAME]: " input_env_name
        ENV_NAME="${input_env_name:-$DEFAULT_ENV_NAME}"
        
        read -p "Primary AWS Region [$DEFAULT_AWS_PRIMARY_REGION]: " input_primary_region
        AWS_PRIMARY_REGION="${input_primary_region:-$DEFAULT_AWS_PRIMARY_REGION}"
        
        read -p "Secondary AWS Region [$DEFAULT_AWS_SECONDARY_REGION]: " input_secondary_region
        AWS_SECONDARY_REGION="${input_secondary_region:-$DEFAULT_AWS_SECONDARY_REGION}"
    fi
    
    # Get AWS Account ID
    AWS_ACCOUNT_ID=$(get_aws_account_id)
    
    # Validate inputs
    validate_inputs
    
    echo
    print_status "Configuration Summary:"
    echo "  App Name:           $APP_NAME"
    echo "  Environment:        $ENV_NAME"
    echo "  AWS Account ID:     $AWS_ACCOUNT_ID"
    echo "  Primary Region:     $AWS_PRIMARY_REGION"
    echo "  Secondary Region:   $AWS_SECONDARY_REGION"
    echo
    
    read -p "Proceed with these settings? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled"
        exit 0
    fi
    
    # Create backup
    backup_files
    
    # Update component configurations
    print_status "Updating VHT project component configurations..."
    
    local total_updates=0
    
    # Update SageMaker components
    for project in vht-payer-propensity-producer vht-claims-denial-mgmt-producer vht-rag-chat-producer vht-analytics-consumer; do
        if [[ -d "iac/roots/sagemaker/$project" ]]; then
            update_directory "iac/roots/sagemaker/$project"
            total_updates=$((total_updates + $?))
        fi
    done
    
    # Update DataZone components
    for project in dz-vht-payer-propensity-producer dz-vht-claims-denial-mgmt-producer dz-vht-rag-chat-producer dz-vht-analytics-consumer; do
        if [[ -d "iac/roots/datazone/$project" ]]; then
            update_directory "iac/roots/datazone/$project"
            total_updates=$((total_updates + $?))
        fi
    done
    
    # Update DataLake components
    for project in vht_payer_propensity_producer vht_claims_denial_mgmt_producer vht_rag_chat_producer vht_analytics_consumer vht_claims_lakehouse; do
        if [[ -d "iac/roots/datalakes/$project" ]]; then
            update_directory "iac/roots/datalakes/$project"
            total_updates=$((total_updates + $?))
        fi
    done
    
    # Verify updates
    verify_updates
    
    # Display summary
    print_success "Total files updated: $total_updates"
    display_summary
}

# Script usage information
usage() {
    echo "Usage: $0 [APP_NAME] [ENV_NAME] [AWS_PRIMARY_REGION] [AWS_SECONDARY_REGION]"
    echo
    echo "Examples:"
    echo "  $0                                    # Interactive mode"
    echo "  $0 vhtds dev us-east-1 us-east-2      # With parameters"
    echo
    echo "Default values:"
    echo "  APP_NAME:             $DEFAULT_APP_NAME"
    echo "  ENV_NAME:             $DEFAULT_ENV_NAME"
    echo "  AWS_PRIMARY_REGION:   $DEFAULT_AWS_PRIMARY_REGION"
    echo "  AWS_SECONDARY_REGION: $DEFAULT_AWS_SECONDARY_REGION"
}

# Handle help flag
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

# Run main function
main "$@"
