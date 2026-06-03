terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

module "day_c_evidence" {
  source = "../../modules/local-file"

  filename = "generated/day-c-module-demo.txt"
  content  = <<EOT
W8-D3 Terraform module demo completed.

What this proves:
- I can call a local Terraform module.
- I understand root module and child module.
- I can run init, fmt, validate, plan, apply, output, and destroy.
EOT
}

output "generated_file" {
  description = "Path of the generated Day C evidence file."
  value       = module.day_c_evidence.file_path
}
