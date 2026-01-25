# 🌍 **AWS Terraform Workshop for Beginners**🚀  

A beginner-friendly guide to setting up AWS infrastructure using **Terraform**! Learn how to **automate** and **manage** cloud resources with ease.  

---

## 📌 **What You'll Learn**  

✅ **Deploy AWS Resources** using Terraform  
✅ **Manage Infrastructure as Code (IaC)**  
✅ **Use Remote State Storage** with S3 + DynamoDB  
✅ **Create VPC, Subnets, and EC2 Instances**  
✅ **Configure Security Groups and Networking**  
✅ **Implement CloudWatch Monitoring**  
✅ **Apply Security Best Practices**  
✅ **Optional: Private Subnets with NAT Gateway**  
✅ **Apply Best Practices** for Terraform Code Structure

---

## 🏗️ **Project Structure (What's Inside?)**  

```tree
AWS-Terraform-Workshop/
│── scripts/          # Shell scripts for user data and setup
│   └── user_data.sh  # Bootstrap script for EC2 instances (Amazon Linux 2023)
│── main.tf           # Main Terraform configuration (VPC, EC2, networking, monitoring)
│── variables.tf      # Input values with validation for easy customization
│── outputs.tf        # Output values of deployed resources
│── backend.tf        # Remote state setup (S3 + DynamoDB)
│── backend-variables.tf # Variables for backend configuration
│── provider.tf       # AWS provider configuration
│── terraform.tfvars.example # Example variable values
│── README.md         # This guide! 📖
```

---

## 🚀 **Getting Started (Step-by-Step)**  

### **1️⃣ Install Required Tools**  

🔹 [Download Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.0.0 or newer)
🔹 Install **AWS CLI** and set up credentials using:  

```sh
aws configure
```

🔹 Create an **S3 bucket & DynamoDB table** for storing Terraform state:

```sh
# Create S3 bucket
aws s3 mb s3://your-terraform-state-bucket --region us-east-1

# Create DynamoDB table (with 'LockID' as partition key)
aws dynamodb create-table \
    --table-name your-terraform-lock-table \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1
```

---

### **2️⃣ Clone the Project & Configure Variables**  

```sh
git clone https://github.com/NotHarshhaa/AWS-Terraform-Workshop.git
cd AWS-Terraform-Workshop

# Create a tfvars file with your specific values
cp terraform.tfvars.example terraform.tfvars
# Edit the terraform.tfvars file with your preferred editor
```

---

### **3️⃣ Initialize Terraform with Backend Configuration**  

```sh
# Basic initialization
terraform init

# Or with custom backend configuration
terraform init \
  -backend-config="bucket=your-terraform-state-bucket" \
  -backend-config="dynamodb_table=your-terraform-lock-table" \
  -backend-config="region=us-east-1"
```

👉 This sets up Terraform by downloading necessary plugins and configuring remote state.

---

### **3️⃣ Alternative: Use Helper Scripts**  

For a safer deployment workflow, use the provided helper scripts:

```sh
# Validate and format your Terraform code
./scripts/validate.sh

# Deploy with safety checks
./scripts/deploy.sh

# Destroy resources with multiple confirmations
./scripts/destroy.sh
```

🔹 **Windows users**: Use Git Bash or WSL to run these shell scripts

---

### **4️⃣ Plan & Apply Changes**  

```sh
# Preview changes
terraform plan -out=tfplan

# Apply the saved plan
terraform apply tfplan

# Or directly apply (will prompt for confirmation)
terraform apply
```

⚡ This will create a complete infrastructure including:
- VPC with proper CIDR blocks
- Public subnet with internet connectivity
- **Optional**: Private subnet with NAT Gateway for secure resources
- Security groups with configurable ports and CIDR restrictions
- EC2 instance with Apache web server (Amazon Linux 2023)
- **IAM roles** for CloudWatch monitoring
- **CloudWatch agent** for metrics collection
- **Enhanced error handling** and logging

---

### **5️⃣ Test the Deployment & View Outputs**

```sh
# View all the output values
terraform output

# Get a specific output value (e.g., web server URL)
terraform output web_url

# SSH to your instance
terraform output ssh_connection_string
# Then modify the command with the actual path to your key file
```

### **6️⃣ Destroy Infrastructure (When Finished)**  

```sh
# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy
```

⛔ This will **delete** all deployed AWS resources.

---

## 📝 **Best Practices for Beginners**

- **Always use Remote State** – Store Terraform state in S3 to prevent conflicts.
- **Use Variables and Outputs** – Parameterize your code for flexibility.
- **Separate User Data Scripts** – Keep bootstrap scripts in separate files.
- **Apply Proper Tagging** – Tag resources consistently for better management.
- **Use Dynamic Blocks** – For repeatable resource configurations.
- **Check Plan Before Applying** – Always run `terraform plan` first!
- **Security First** – Restrict security group rules to minimum required access.
- **Input Validation** – Add validation rules to prevent misconfiguration.
- **Monitoring & Logging** – Implement CloudWatch for observability.
- **Error Handling** – Use proper error handling in user data scripts.
- **Latest AMIs** – Always use updated AMIs for security patches.

---

## 🚀 **Advanced Features**  

### **Private Subnet with NAT Gateway**  

Enable private subnet creation by setting:  
```hcl
enable_private_subnet = true
private_subnet_cidr   = "10.0.2.0/24"
```  

This creates:  
- Private subnet isolated from the internet  
- NAT Gateway for outbound internet access  
- Private route table  
- Elastic IP for NAT Gateway  

### **Security Enhancements**  

- **CIDR Restrictions**: Limit SSH access to specific IP ranges  
- **IAM Roles**: Least privilege access for EC2 instances  
- **CloudWatch Monitoring**: Automated metrics collection  

### **Monitoring & Observability**  

- **CloudWatch Metrics**: CPU, Memory, Disk utilization  
- **Instance Metadata**: Dynamic display on web page  
- **Error Logging**: Comprehensive error handling in user data  

---  

## 🤝 **Contributing**  

🔹 Found something to improve? Open a **pull request**!  
🔹 Have questions? Feel free to **open an issue**!  
🔹 Want to extend? Add more resources like RDS, S3, or Lambda!

---

## 📜 **License**  

📝 This project is licensed under **MIT License** – Free to use and modify!  

## 📚 **Additional Resources**

🔹 [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
🔹 [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
🔹 [Terraform Best Practices](https://www.terraform-best-practices.com/)

🚀 **Happy Terraforming!** 🌍

---

## **⭐ Hit the Star!**  

If you find this repository helpful and plan to use it for learning, please consider giving it a star ⭐. Your support motivates me to keep improving and adding more valuable content! 🚀  

---

## 🛠️ **Author & Community**  

This project is crafted with passion by **[Harshhaa](https://github.com/NotHarshhaa)** 💡.  

I’d love to hear your feedback! Feel free to open an issue, suggest improvements, or just drop by for a discussion. Let’s build a strong DevOps community together!  

---

## 📧 **Let's Connect!**  

Stay connected and explore more DevOps content with me:  

[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/harshhaa-vardhan-reddy)  [![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/NotHarshhaa)  [![Telegram](https://img.shields.io/badge/Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/prodevopsguy)  [![Dev.to](https://img.shields.io/badge/Dev.to-0A0A0A?style=for-the-badge&logo=dev.to&logoColor=white)](https://dev.to/notharshhaa)  [![Hashnode](https://img.shields.io/badge/Hashnode-2962FF?style=for-the-badge&logo=hashnode&logoColor=white)](https://hashnode.com/@prodevopsguy)  

---

## 📢 **Stay Updated!**  

Want to stay up to date with the latest DevOps trends, best practices, and project updates? Follow me on my blogs and social channels!  

![Follow Me](https://imgur.com/2j7GSPs.png)
