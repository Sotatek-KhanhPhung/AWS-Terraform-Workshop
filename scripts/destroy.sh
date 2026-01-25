#!/bin/bash

# Terraform destruction script with safety checks
# This script provides a safe way to destroy all resources

set -e

echo "🧹 Terraform Destruction Script"
echo "==============================="

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
    echo -e "${RED}🚨 $message${NC}"
    read -p "Type 'destroy' to confirm: " -r
    echo
    if [[ $REPLY != "destroy" ]]; then
        print_status "info" "Operation cancelled by user"
        exit 0
    fi
}

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_status "error" "Terraform is not installed or not in PATH"
    exit 1
fi

# Check if .terraform directory exists
if [ ! -d ".terraform" ]; then
    print_status "warning" "Terraform not initialized"
    print_status "info" "Initializing Terraform..."
    terraform init -no-color
    print_status "success" "Terraform initialized"
fi

# Show current state
print_status "info" "Current Terraform state:"
terraform show -no-color

# Show destroy plan
print_status "info" "Generating destroy plan..."
terraform plan -destroy -no-color

# Multiple confirmation steps
echo ""
print_status "warning" "This will permanently delete ALL resources created by this Terraform configuration!"
echo ""
confirm_action "Are you sure you want to destroy all resources?"

confirm_action "This action cannot be undone. All data will be lost. Continue?"

# Final confirmation
echo ""
print_status "info" "Resources to be destroyed:"
terraform state list | while read -r resource; do
    echo "   - $resource"
done

echo ""
confirm_action "Final confirmation: Destroy all listed resources?"

# Destroy resources
print_status "info" "Destroying Terraform resources..."
if terraform destroy -no-color -auto-approve; then
    print_status "success" "All resources destroyed successfully"
else
    print_status "error" "Destruction failed"
    exit 1
fi

# Clean up local files
print_status "info" "Cleaning up local files..."
rm -f tfplan
rm -f .terraform.lock.hcl
rm -rf .terraform/

print_status "success" "Cleanup completed!"
echo ""
echo "✅ All AWS resources have been destroyed"
echo "✅ Local Terraform files cleaned up"
echo ""
echo "🔄 To redeploy: Run ./scripts/deploy.sh"
