# W8 Online Test 1 — Terraform Prep

## 1. IaC

### What is IaC?
Infrastructure as Code means managing infrastructure using code instead of clicking manually in a console.

### Why IaC?
- repeatable
- reviewable in Git
- easier to automate
- easier to reproduce environments
- reduces manual mistakes

## 2. Terraform Basics

### Provider
A plugin Terraform uses to talk to a platform or API, such as AWS, Kubernetes, GitHub, Docker, or local.

### Resource
An object Terraform manages, such as an EC2 instance, S3 bucket, VPC, or local file.

### Variable
Input value used to make configuration flexible.

### Output
Value Terraform prints after apply, often used to show important information.

## 3. HCL Syntax

Basic block structure:

```hcl
block_type "label_1" "label_2" {
  argument = value
}
```

Example:

```hcl
resource "local_file" "example" {
  filename = "hello.txt"
  content  = "Hello Terraform"
}
```

## 4. Terraform Workflow

| Command | Meaning |
|---|---|
| `terraform init` | Initialize working directory and download providers/modules |
| `terraform fmt` | Format Terraform code |
| `terraform validate` | Check whether configuration is valid |
| `terraform plan` | Preview changes before applying |
| `terraform apply` | Execute the planned changes |
| `terraform output` | Show output values |
| `terraform destroy` | Destroy managed resources |

## 5. State

### What is terraform.tfstate?
A file that stores Terraform's record of managed infrastructure.

### Why is state needed?
Terraform uses state to map real infrastructure objects to resource blocks in code.

### Why not commit state?
- It can contain sensitive values.
- It changes frequently.
- It may cause conflicts.

## 6. Remote State

Remote state stores state in a shared backend such as S3 or HCP Terraform.

Benefits:
- team collaboration
- CI/CD access
- safer source of truth

## 7. State Locking

State locking prevents two Terraform runs from writing state at the same time.

## 8. Modules

A module is a collection of Terraform resources managed together.

Benefits:
- reuse code
- standardize infrastructure
- keep projects organized

## 9. Best Practices

- Run `terraform fmt` before commit.
- Run `terraform validate` before plan/apply.
- Always inspect `terraform plan`.
- Do not commit `.terraform/`, `.tfstate`, `.tfvars`, or secrets.
- Use clear variable names.
- Use modules when code is repeated or logically grouped.
