# W8-D3 — Terraform State, Remote Backend, Modules, Best Practices

## Goal
Complete Day C checklist:
- Learn Terraform state management
- Understand remote state using S3 backend
- Understand state locking and why teams need it
- Learn Terraform modules
- Write an ADR
- Prepare questions for mentor Minh
- Prepare for Online Test 1
- Run a local Terraform module demo

## Important note about S3 + DynamoDB locking
Older Terraform projects commonly use S3 for remote state and DynamoDB for state locking.
Current Terraform documentation says S3 backend supports locking through S3 or DynamoDB, but DynamoDB-based locking is deprecated and will be removed in a future minor version.

For this learning day, we still study S3 + DynamoDB because it appears in the program checklist, but production projects should follow the current Terraform docs.

## How to run the module demo
```bash
cd cloud/w8/day-c/examples/module-demo
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```

## Expected evidence
After `terraform apply`, Terraform creates:

```text
generated/day-c-module-demo.txt
```

Save terminal output or screenshots in:

```text
cloud/w8/day-c/evidence/
```
