---
title: "IT LAB 9 - Cloud Infrastructure Provisioning with Terraform"
parent: Labs
nav_order: 109
---

# IT LAB 9 - Cloud Infrastructure Provisioning with Terraform
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 9 &nbsp;·&nbsp; **Track:** IT
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Deploy a multi-tier AWS architecture using Terraform (VPC, subnets, security groups, EC2, RDS)
- Implement remote state with S3 backend and state locking with DynamoDB
- Use Terraform modules to enforce reusable, consistent infrastructure patterns
- Tag all resources for cost allocation and compliance tracking
- Produce a `terraform plan` output for a proposed change and interpret it for a change advisory board

---

## Tools Required

- AWS Academy Learner Lab or equivalent AWS sandbox account
- Terraform v1.5+ (`terraform --version`)
- AWS CLI v2 configured with sandbox credentials
- Text editor / IDE

---

## Background

Infrastructure as Code (IaC) is the practice of defining infrastructure in version-controlled configuration files rather than through manual console operations. Terraform's declarative model means you describe the desired state, and Terraform calculates the diff between current and desired, showing you exactly what will be created, modified, or destroyed before you apply.

This lab treats IaC as a production discipline: remote state prevents concurrent modifications from corrupting infrastructure, modules enforce standards, and tagging enables cost reporting to business units.

---

## Procedure

### Part 1 - Terraform Project Structure and Remote State (30 min)

**1.1 Create project directory structure**

```
cloud-lab/
 main.tf
 variables.tf
 outputs.tf
 terraform.tfvars
 backend.tf
 modules/
     vpc/
        main.tf
        variables.tf
        outputs.tf
     webserver/
         main.tf
         variables.tf
         outputs.tf
```

**1.2 Configure S3 remote state backend**

First, create the S3 bucket and DynamoDB table manually (one-time bootstrap):

```bash
# Create state bucket (use a unique name - S3 bucket names are globally unique)
aws s3api create-bucket \
    --bucket tfstate-lab-$(aws sts get-caller-identity --query Account --output text) \
    --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket tfstate-lab-$(aws sts get-caller-identity --query Account --output text) \
    --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
    --bucket tfstate-lab-$(aws sts get-caller-identity --query Account --output text) \
    --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}'

# Create DynamoDB lock table
aws dynamodb create-table \
    --table-name terraform-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
```

**1.3 Write `backend.tf`**

```hcl
terraform {
  backend "s3" {
    bucket         = "tfstate-lab-<your-account-id>"
    key            = "cloud-lab/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
```

---

### Part 2 - VPC Module (40 min)

**`modules/vpc/variables.tf`**

```hcl
variable "vpc_cidr"            { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs"{ type = list(string) }
variable "azs"                 { type = list(string) }
variable "project_name"        { type = string }
variable "environment"         { type = string }
```

**`modules/vpc/main.tf`**

```hcl
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project_name}-igw" }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.project_name}-public-${count.index + 1}"
    Tier        = "public"
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]
  tags = {
    Name        = "${var.project_name}-private-${count.index + 1}"
    Tier        = "private"
    ManagedBy   = "terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "${var.project_name}-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${var.project_name}-nat" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = { Name = "${var.project_name}-private-rt" }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
```

**`modules/vpc/outputs.tf`**

```hcl
output "vpc_id"             { value = aws_vpc.this.id }
output "public_subnet_ids"  { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
```

---

### Part 3 - Web Server Module and Main Configuration (50 min)

**`modules/webserver/main.tf`**

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-web-"
  vpc_id      = var.vpc_id
  description = "Web server security group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
    description = "SSH from admin network only"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-web-sg", ManagedBy = "terraform" }
}

resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = var.instance_profile

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable --now nginx
    echo "<h1>Web Server ${count.index + 1} - ${var.environment}</h1>" \
        > /usr/share/nginx/html/index.html
  EOF
  )

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # Enforce IMDSv2
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
    tags        = { Name = "${var.project_name}-web-${count.index + 1}-root" }
  }

  tags = {
    Name        = "${var.project_name}-web-${count.index + 1}"
    Environment = var.environment
    ManagedBy   = "terraform"
    CostCenter  = var.cost_center
  }
}
```

**`main.tf` (root module)**

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "IT-Operations"
    }
  }
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  project_name         = var.project_name
  environment          = var.environment
}

module "web" {
  source          = "./modules/webserver"
  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnet_ids
  instance_count  = 2
  instance_type   = "t3.micro"
  admin_cidr      = var.admin_cidr
  cost_center     = "IT-Ops-Lab"
  instance_profile = ""
}
```

**`terraform.tfvars`**

```hcl
aws_region           = "us-east-1"
project_name         = "cloudlab"
environment          = "dev"
vpc_cidr             = "10.20.0.0/16"
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]
azs                  = ["us-east-1a", "us-east-1b"]
admin_cidr           = "0.0.0.0/0"  # Restrict in production
```

---

### Part 4 - Plan, Apply, and Verify (30 min)

```bash
cd cloud-lab
terraform init
terraform validate
terraform fmt -recursive

# Review the plan - capture this output for your deliverable
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary | python3 -m json.tool | head -100

# Apply
terraform apply tfplan.binary

# Verify outputs
terraform output
```

Verify the deployed infrastructure:

```bash
# List created resources
terraform state list

# Verify instances are running
aws ec2 describe-instances \
    --filters "Name=tag:Project,Values=cloudlab" \
    --query "Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]" \
    --output table

# Curl each web server
for ip in $(terraform output -json web_public_ips 2>/dev/null | jq -r '.[]' 2>/dev/null); do
    curl -s http://$ip/ || echo "Trying instance $ip..."
done
```

---

### Part 5 - Change Management: Plan Output for CAB (30 min)

A change request to add a third web server and change instance type from `t3.micro` to `t3.small` needs CAB approval. Modify `terraform.tfvars`:

```hcl
instance_count = 3      # was 2
instance_type  = "t3.small"  # was t3.micro
```

Generate and capture the plan **without applying**:

```bash
terraform plan 2>&1 | tee proposed_change_plan.txt
```

Write a **CAB Submission** that interprets the Terraform plan for non-technical reviewers:
- What is being changed?
- How many resources will be added/modified/destroyed?
- Is any data at risk? (e.g., will EC2 instances be destroyed and recreated?)
- What is the rollback procedure if the change causes issues?
- Estimated cost impact (use AWS pricing data)

**Do NOT run `terraform apply` on this change** - submit the plan output and CAB document only.

---

### Part 6 - Cleanup

```bash
terraform destroy -auto-approve
```

Verify all resources are removed: `terraform state list` should return empty.

---

## Deliverables

1. Complete Terraform project (all `.tf` files - paste into submission)
2. `terraform plan` output from initial deployment
3. `terraform state list` output after successful apply
4. AWS console screenshots or CLI output showing running instances with correct tags
5. Proposed change `terraform plan` output for the third-instance change
6. CAB Submission document interpreting the plan for non-technical reviewers

---

## Grading

| Item | Points |
|------|--------|
| VPC module with all components (IGW, NAT, subnets, route tables) | 25 |
| Web server module with IMDSv2, encrypted volumes, tagging | 25 |
| Remote state with S3 + DynamoDB backend | 15 |
| Successful apply with verification evidence | 20 |
| CAB Submission document for proposed change | 15 |
| **Total** | **100** |

---

{: .callout-grad }
> ##  Graduate Extension (CS/IT 544 - Master's Students Only)
>
> **This section is required for graduate students. +30 points.**
>
> ### Extension A - Terraform Sentinel Policy as Code
>
> In enterprise environments, Terraform runs are gated by policy checks that enforce organizational standards before any `apply` is permitted. Implement Open Policy Agent (OPA) policies to enforce:
>
> 1. **Tagging enforcement**: Every resource must have `Environment`, `Project`, `ManagedBy`, and `CostCenter` tags. Write an OPA Rego policy that fails if any resource is missing a required tag.
>
> 2. **Instance type allowlist**: Only `t3.micro`, `t3.small`, and `t3.medium` are permitted in `dev` environments. Write a policy that blocks larger instance types.
>
> 3. **Public S3 bucket prevention**: No S3 bucket may have `acl = "public-read"` or `"public-read-write"`.
>
> Test each policy against a Terraform plan JSON file. Show policy pass and fail outputs.
>
> ### Extension B - Cost Estimation and FinOps Analysis
>
> Cloud cost governance is a key responsibility of senior IT engineers. Using the Infracost CLI:
>
> 1. Install Infracost: `curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh`
>
> 2. Run: `infracost breakdown --path . --format json > cost_report.json`
>
> 3. Analyze the cost report and produce a **Cloud Cost Report** for your manager:
>    - Monthly estimated cost broken down by service (EC2, VPC, NAT Gateway, etc.)
>    - Which single resource accounts for the highest percentage of cost?
>    - Propose 3 specific optimizations that would reduce the monthly cost by at least 30% without reducing availability (e.g., Reserved Instances, Savings Plans, eliminating NAT Gateway for dev)
>    - Estimate the savings from each optimization
>
> Submit OPA policy files with test outputs and the Infracost report with 300-word optimization analysis.

[← Back to Labs]({{ site.baseurl }}/labs/)
