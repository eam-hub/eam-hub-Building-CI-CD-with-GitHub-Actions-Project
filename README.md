

# 🚀 CI/CD Pipeline with GitHub Actions, Terraform, Docker & AWS

This project demonstrates how to create a robust **CI/CD pipeline** using **GitHub Actions** for deploying infrastructure and applications to **AWS** using **Terraform**, **Docker**, **ECR**, **ECS Fargate**, and **Secrets Manager**.

---

## 🛠️ Prerequisites

Ensure the following tools are installed and configured:

* [Terraform](https://developer.hashicorp.com/terraform/install)
* [Git](https://git-scm.com/)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Visual Studio Code](https://code.visualstudio.com/)

  * Extensions: `Terraform`, `HashiCorp`
* [GitHub Account](https://github.com/)
* Create an IAM user in AWS with **Administrator Access**
* Run `aws configure` to set up your credentials locally

---

## 📁 Repository Structure

```plaintext
.github/
└── workflows/
    └── deploy_pipeline.yml     # GitHub Actions workflow file

terraform/
├── main.tf                     # Terraform infrastructure configuration
├── backend.tf                  # S3 & DynamoDB state locking
├── variables.tf
├── terraform.tfvars            # Input values
└── outputs.tf

sql/
└── migration_script.sql        # SQL script used by Flyway

Dockerfile                      # For building the application image
appserviceprovider.php          # Forces HTTPS redirection
```

---

## 🔐 GitHub Repository Secrets

Store the following secrets in your GitHub repo:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `ECR_REGISTRY`
* `PERSONAL_ACCESS_TOKEN`
* `RDS_DB_NAME`
* `RDS_DB_PASSWORD`
* `RDS_DB_USERNAME`

---

## 🧪 Testing Infrastructure with Terraform

1. Clone the private GitHub repository:

   ```bash
   git clone <your-repo-url>
   cd <repo-folder>
   ```

2. Update `.gitignore` to include `.tfvars` files if needed.

3. Run:

   ```bash
   terraform init
   terraform apply
   terraform destroy
   ```

---

## ☁️ Backend Configuration

* **S3 Bucket** for storing the Terraform state file
* **DynamoDB** for state locking
* **Secrets Manager** to store RDS credentials securely
* **Route 53** to register and map a domain name

---

## 🧱 GitHub Actions Workflow Jobs

### ✅ 1. Configure AWS Credentials

➡️ See `"configure aws credentials"` section in `deploy_pipeline.yml`

Authenticates with AWS using GitHub secrets.

---

### 🏗️ 2. Build AWS Infrastructure

➡️ See `"build aws infrastructure"` section in `deploy_pipeline.yml`

Uses Terraform to create:

* VPC, Subnets, NAT Gateway, Internet Gateway
* ALB, Security Groups
* ECS Cluster, ECS Service
* S3, RDS, IAM Roles
* Route 53

---

### 🔥 3. Destroy AWS Infrastructure

➡️ See `"build aws infrastructure"` section in `deploy_pipeline.yml` (Change `apply` to `destroy` on line 11)

Tears down all infrastructure when triggered. Useful for cleanup.

---

### 🐳 4. Create ECR Repository

➡️ See `"Create ECR repository"` section in `deploy_pipeline.yml`

Prepares an Amazon ECR registry for storing Docker images.

---

## 🏃‍♂️ Self-Hosted EC2 Runner Setup

1. Launch EC2 instance (Amazon Linux 2)
2. SSH into it:

   ```bash
   ssh -i "your-key.pem" ec2-user@<public-ip>
   ```
3. Install Docker & Git:

   ```bash
   sudo yum update -y
   sudo yum install docker git libicu -y
   sudo systemctl enable docker
   ```
4. Create AMI from EC2 and then **terminate** the EC2 instance.

---

### 🖥️ 5. Start Self-Hosted EC2 Runner

➡️ See `"Start self-hosted EC2 runner"` section in `deploy_pipeline.yml`

Launches EC2 instance from the AMI into the private subnet.
🧵 Runs in **parallel** with the `"Create ECR repository"` job.

---

## 🧱 Application Deployment

### 📦 6. Build & Push Docker Image to ECR

➡️ See `"Build and push Docker image to ECR"` section in `deploy_pipeline.yml`

1. Create a new repo for application code
2. Clone it and add source code
3. Add:

   * `Dockerfile`
   * `appserviceprovider.php` (for HTTPS redirection)
4. This job builds the image and pushes it to ECR

---

### 🧾 7. Create Environment File & Upload to S3

➡️ See `"Create environment file and export to S3"` section in `deploy_pipeline.yml`

Generates a `.env` file and uploads it to S3, so ECS tasks can access environment variables.

---

## 🛢️ Database Migration

Before running the next job:

* Create a `sql/` folder
* Add migration script (`.sql`)

### 🧬 8. Migrate Data into RDS using Flyway

➡️ See `"Migrate data into RDS database with Flyway"` section in `deploy_pipeline.yml`

Executes Flyway from the self-hosted EC2 runner to apply SQL migrations to the RDS instance.

---

### 🛑 9. Stop the Self-Hosted EC2 Runner

➡️ See `"Stop the self-hosted EC2 runner"` section in `deploy_pipeline.yml`

Terminates the self-hosted runner after its job completes to avoid reuse (e.g., Flyway conflict).

---

## ⚙️ ECS Deployment

### 🆕 10. Create ECS Task Definition Revision

➡️ See `"Create new task definition revision"` section in `deploy_pipeline.yml`

Creates a new task definition revision that uses the Docker image built earlier.

---

### 🔁 11. Restart ECS Fargate Service

➡️ See `"Restart ECS Fargate service"` section in `deploy_pipeline.yml`

Forces ECS Fargate to deploy the new task definition so your latest application image is live.

---

## 🌐 Final Deployment Test

Open your registered **Route 53 domain name** in a browser.
✅ The deployed application should load successfully over **HTTPS**.

---

## 📘 Running the Pipeline

To deploy:

* Push code to `main` branch (or configured trigger)
* GitHub Actions will automatically run the workflow

To destroy:

* Change `terraform apply` to `terraform destroy` in the `"build aws infrastructure"` job

---

## 🧾 Notes

* Ensure `.tfvars` files are **not excluded** if needed in pipeline
* Use **AWS Secrets Manager** and **GitHub Secrets** for sensitive data
* Keep your runner AMIs updated for security and compatibility

---

