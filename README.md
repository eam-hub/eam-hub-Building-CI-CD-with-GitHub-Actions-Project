Here's a comprehensive **README.md** for your GitHub repository, based on your detailed CI/CD pipeline project using **GitHub Actions**, **Terraform**, **AWS**, and **Docker**.

---

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

### 1. Configure AWS Credentials

Authenticate with AWS using the credentials stored as GitHub Secrets.

### 2. Build AWS Infrastructure

Deploy VPC, Subnets, ALB, Security Groups, ECS Cluster, RDS, S3, and Route 53.

### 3. Destroy AWS Infrastructure

Destroys all previously created resources. To trigger this, change:

```yaml
terraform apply
```

to:

```yaml
terraform destroy
```

### 4. Create ECR Repository

Prepares a private Docker registry in AWS to store the image.

---

## 🏃‍♂️ Self-Hosted Runner (EC2)

1. Create a key pair
2. Launch EC2 (Amazon Linux 2)
3. SSH into the instance and install Docker, Git
4. Create an AMI from the EC2
5. Terminate the EC2 (we'll use the AMI)

### 5. Start Self-Hosted EC2 Runner

Use the AMI to launch the EC2 instance in the private subnet to serve as the runner.

---

## 🐳 Docker Build & Push

### 6. Build and Push Docker Image

Clone the `application-codes` repo and:

* Add application source code
* Create `Dockerfile`
* Add `appserviceprovider.php` to redirect HTTP → HTTPS
* This job builds and pushes the Docker image to ECR

---

## 📦 Environment Variables

### 7. Create & Upload Environment File to S3

Generate a `.env` file and upload to S3 for ECS to access environment variables.

---

## 🛢️ Database Migration

### 8. Migrate Data into RDS using Flyway

Before this step:

* Create `/sql` folder
* Place your `.sql` migration script there

Runs Flyway inside the EC2 runner to apply the SQL script.

---

## 🛑 Stop Runner

### 9. Stop Self-Hosted EC2 Runner

Terminates the EC2 runner to avoid reuse (Flyway conflicts if reused).

---

## 🔁 ECS & Deployment

### 10. Create ECS Task Definition Revision

Updates ECS task definition to use the newly built Docker image.

### 11. Restart ECS Fargate Service

Restarts ECS service to use the latest task definition.

---

## 🌐 Deployment Test

* Visit your **Route 53 domain name** in the browser.
* Application should be live and served over HTTPS.

---

## 📘 How to Run the Pipeline

To deploy:

* Push code to `main` branch (or configure trigger branch)
* GitHub Actions will handle the deployment pipeline

To destroy:

* Change `terraform apply` → `terraform destroy` in the workflow

---

## 🧾 Notes

* Use `.gitignore` responsibly — include `.tfvars` during pipeline development
* Store sensitive data only in **AWS Secrets Manager** or **GitHub Secrets**
* Make sure all job dependencies and sequencing are clearly defined in the YAML file

---

## 🤝 Credits

Infrastructure pipeline inspired by modern DevOps practices using GitHub Actions, Terraform, and AWS services.

---

Let me know if you'd like the actual `deploy_pipeline.yml` sample or any diagrams added.
