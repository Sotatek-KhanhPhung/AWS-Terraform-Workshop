#!/bin/bash

# Terraform validation and formatting script
# This script validates and formats all Terraform files in the project

set -e

echo "🔍 Terraform Validation & Formatting Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "success")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "error")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "info")
            echo -e "ℹ️  $message"
            ;;
    esac
}

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_status "error" "Terraform is not installed or not in PATH"
    exit 1
fi

print_status "info" "Terraform version: $(terraform version -json | jq -r '.terraform_version')"

# Initialize Terraform (if not already initialized)
if [ ! -d ".terraform" ]; then
    print_status "info" "Initializing Terraform..."
    terraform init -no-color
    print_status "success" "Terraform initialized"
else
    print_status "info" "Terraform already initialized"
fi

# Validate Terraform configuration
print_status "info" "Validating Terraform configuration..."
if terraform validate -no-color; then
    print_status "success" "Terraform validation passed"
else
    print_status "error" "Terraform validation failed"
    exit 1
fi

# Check Terraform formatting
print_status "info" "Checking Terraform formatting..."
if terraform fmt -check -recursive -no-color; then
    print_status "success" "Terraform files are properly formatted"
else
    print_status "warning" "Terraform files need formatting"
    print_status "info" "Running terraform fmt to fix formatting..."
    terraform fmt -recursive -no-color
    print_status "success" "Terraform files have been formatted"
fi

# Run terraform plan to check for potential issues
print_status "info" "Running terraform plan to check for potential issues..."
if terraform plan -no-color -out=tfplan; then
    print_status "success" "Terraform plan completed without errors"
    
    # Clean up the plan file
    rm -f tfplan
else
    print_status "error" "Terraform plan failed"
    exit 1
fi

# Check for common Terraform best practices
print_status "info" "Checking for common Terraform best practices..."

# Check if variables.tf has validation rules
if grep -q "validation" variables.tf; then
    print_status "success" "Variable validation rules found"
else
    print_status "warning" "Consider adding validation rules for variables"
fi

# Check if resources have proper tags
if grep -q "merge.*var.tags" main.tf; then
    print_status "success" "Resources are using consistent tagging"
else
    print_status "warning" "Consider using consistent tagging across resources"
fi

# Check if security group has CIDR restrictions
if grep -q "allowed_ssh_cidr" main.tf; then
    print_status "success" "Security group uses CIDR restrictions"
else
    print_status "warning" "Consider adding CIDR restrictions for security groups"
fi

# Check for lifecycle blocks
if grep -q "lifecycle" main.tf; then
    print_status "success" "Lifecycle blocks found for resource management"
else
    print_status "info" "Consider adding lifecycle blocks for better resource management"
fi

print_status "success" "Validation and formatting completed successfully!"
echo ""
echo "📋 Summary:"
echo "   ✅ Terraform configuration is valid"
echo "   ✅ Files are properly formatted"
echo "   ✅ Plan executed without errors"
echo "   ✅ Best practices checked"
echo ""
echo "🚀 Ready to deploy with: terraform apply"
