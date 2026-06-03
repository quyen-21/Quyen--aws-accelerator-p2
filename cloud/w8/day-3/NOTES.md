# W8-D3 Notes — Terraform State, Remote Backend, Modules, Best Practices

## 1. Terraform State

Terraform state is the file Terraform uses to remember which real infrastructure objects belong to which resources in the `.tf` code.

Example:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxx"
  instance_type = "t3.micro"
}
```

Terraform needs state to know which real EC2 instance is `aws_instance.web`.

### Why Terraform needs state

Terraform state helps Terraform:

- map real resources to Terraform resource blocks
- compare current configuration with real infrastructure
- decide what to create, update, or destroy
- track metadata about resources

Simple explanation:

```text
Terraform code = what I want
Real cloud = what currently exists
Terraform state = what Terraform remembers and manages
```

## 2. Local State

By default, Terraform stores state locally:

```text
terraform.tfstate
```

Local state is fine for learning or solo practice, but it is risky for teamwork because only one machine has the latest state.

Problems with local state:

- Easy to lose
- Hard to share with team members
- Can cause conflict if two people run Terraform separately
- May contain sensitive data

## 3. Remote State

Remote state means storing Terraform state in a shared backend, such as:

- HCP Terraform
- Amazon S3
- Google Cloud Storage
- Azure Storage

For AWS teams, a common setup is:

```text
S3 bucket       -> stores terraform.tfstate
State locking   -> prevents concurrent writes
```

Remote state is useful because all team members and CI/CD pipelines read the same source of truth.

## 4. State Locking

State locking prevents two users or automation jobs from changing the same state at the same time.

Without locking:

```text
User A: terraform apply
User B: terraform apply at the same time
Result: state conflict or corrupted state
```

With locking:

```text
User A gets the lock
User B must wait
State stays safe
```

## 5. S3 Backend and DynamoDB Lock

Older AWS Terraform patterns use:

```text
S3 bucket      -> remote state storage
DynamoDB table -> lock table
```

Current Terraform docs say S3 backend supports locking through S3 or DynamoDB, but DynamoDB-based locking is deprecated and will be removed in a future minor version.

For this course checklist, understand both:

| Component | Role |
|---|---|
| S3 bucket | Stores the state file |
| DynamoDB table | Older/common locking mechanism |
| S3 native lockfile | Newer S3-based locking option |
| encryption | Protects state at rest |
| key | Path to the state object inside bucket |

## 6. Terraform Modules

A module is a collection of Terraform resources managed together.

There are two types in normal practice:

| Type | Meaning |
|---|---|
| Root module | The current Terraform folder where you run commands |
| Child module | A reusable module called from the root module |

Example:

```hcl
module "day_c_evidence" {
  source = "../../modules/local-file"

  filename = "generated/day-c-module-demo.txt"
  content  = "W8-D3 Terraform module demo completed."
}
```

Why use modules:

- avoid repeated code
- organize infrastructure clearly
- reuse standard patterns
- make project easier to maintain

## 7. Terraform Best Practices

### File organization

Common structure:

```text
main.tf
variables.tf
outputs.tf
versions.tf
backend.tf
terraform.tfvars.example
```

### Git safety

Do not commit:

```text
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
*.tfplan
```

Why:

- state can contain sensitive values
- tfvars may contain passwords or access keys
- local provider cache is not needed in Git

### Workflow best practices

Always run:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```

Use `plan` before `apply` because it shows what Terraform will change before touching infrastructure.

### Naming best practices

Use clear names:

```hcl
resource "aws_s3_bucket" "terraform_state" {}
module "network" {}
variable "environment" {}
output "bucket_name" {}
```

Avoid vague names:

```hcl
resource "aws_s3_bucket" "test" {}
variable "x" {}
```

## 8. Day C Summary

By the end of Day C, I should be able to explain:

- What Terraform state is
- Why remote state is needed in teams
- Why state locking matters
- How S3 backend works
- Why DynamoDB lock was commonly used
- What Terraform modules are
- How to create and call a simple local module
- Which Terraform files should not be committed
