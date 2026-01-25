#!/bin/bash

# Terraform deployment script with safety checks
# This script provides a safe deployment workflow

set -e

echo "🚀 Terraform Deployment Script"
echo "=============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Function to confirm action
confirm_action() {
    local message=$1
    echo -e "${YELLOW}⚠️  $message${NC}"
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "info" "Operation cancelled by user"
        exit 0
    fi
}

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_status "error" "Terraform is not installed or not in PATH"
    exit 1
fi

print_status "info" "Terraform version: $(terraform version -json | jq -r '.terraform_version')"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_status "warning" "terraform.tfvars file not found"
    if [ -f "terraform.tfvars.example" ]; then
        print_status "info" "Found terraform.tfvars.example"
        print_status "info" "Copy terraform.tfvars.example to terraform.tfvars and customize"
        cp terraform.tfvars.example terraform.tfvars
        print_status "success" "Created terraform.tfvars from example"
        print_status "warning" "Please edit terraform.tfvars with your values before proceeding"
        exit 1
    else
        print_status "error" "No terraform.tfvars.example found"
        exit 1
    fi
fi

# Validate terraform.tfvars
print_status "info" "Validating terraform.tfvars file..."
if terraform fmt -no-color > /dev/null 2>&1; then
    print_status "success" "terraform.tfvars is valid"
else
    print_status "error" "terraform.tfvars has syntax errors"
    exit 1
fi

# Initialize Terraform
print_status "info" "Initializing Terraform..."
if terraform init -no-color; then
    print_status "success" "Terraform initialized"
else
    print_status "error" "Terraform initialization failed"
    exit 1
fi

# Validate configuration
print_status "info" "Validating Terraform configuration..."
if terraform validate -no-color; then
    print_status "success" "Configuration is valid"
else
    print_status "error" "Configuration validation failed"
    exit 1
fi

# Format files
print_status "info" "Formatting Terraform files..."
terraform fmt -recursive -no-color
print_status "success" "Files formatted"

# Show plan
print_status "info" "Generating execution plan..."
terraform plan -no-color

# Ask for confirmation before applying
confirm_action "This will create/modify AWS resources and may incur costs."

# Apply changes
print_status "info" "Applying Terraform changes..."
if terraform apply -no-color -auto-approve; then
    print_status "success" "Terraform apply completed successfully"
else
    print_status "error" "Terraform apply failed"
    exit 1
fi

# Show outputs
print_status "info" "Deployment outputs:"
terraform output -no-color

print_status "success" "Deployment completed successfully!"
echo ""
echo "📋 Next Steps:"
echo "   🌐 Access your web server: $(terraform output -raw web_url 2>/dev/null || echo 'Run terraform output web_url')"
echo "   🔑 SSH to instance: $(terraform output -raw ssh_connection_string 2>/dev/null || echo 'Run terraform output ssh_connection_string')"
echo "   📊 Check CloudWatch metrics for monitoring"
echo ""
echo "🧹 To destroy resources when done: terraform destroy"
