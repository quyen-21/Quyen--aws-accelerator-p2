# ADR-001: Terraform State and Module Structure

## Status
Accepted for W8-D3 learning exercise.

## Context
Phase 2 Cloud/DevOps requires each student to manage infrastructure as code using Terraform.
Terraform requires state to track the relationship between configuration and real infrastructure.

For individual local practice, local state is simple and free.
For team or production usage, local state is risky because multiple people may run Terraform and create conflicting state changes.

The course checklist mentions S3 and DynamoDB lock. This is a common AWS Terraform pattern. However, current Terraform S3 backend documentation says DynamoDB-based locking is deprecated and will be removed in a future minor version, so newer projects should check the current recommended S3 locking configuration.

## Decision
For W8-D3 practice:

1. Use local state for the module demo because it only creates a local file.
2. Document S3 backend as the recommended team/production remote state pattern.
3. Document DynamoDB lock as an older/common pattern that appears in many existing Terraform projects.
4. Prefer reusable module structure for repeated Terraform code.

## Reason
- Local state is enough for a safe local exercise.
- Remote state allows team members and CI/CD pipelines to share the same Terraform state.
- Locking prevents concurrent Terraform operations from corrupting state.
- Modules make Terraform code reusable, cleaner, and easier to maintain.

## Consequences
- The demo can be run without AWS and without cost.
- Production projects need extra setup for a backend bucket and locking.
- The repository has more folders, but the structure is closer to real Terraform projects.
