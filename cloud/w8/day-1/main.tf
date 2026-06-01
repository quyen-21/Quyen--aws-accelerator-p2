resource "random_pet" "evidence_suffix" {
  length    = 2
  separator = "-"
}

resource "local_file" "w8_d1_evidence" {
  filename = "${path.module}/generated/w8-d1-hello.txt"

  content = <<EOT
Hello Terraform!

Student: ${var.student_name}
Course: ${var.course_name}
Day: ${var.day_code}
Evidence ID: ${random_pet.evidence_suffix.id}

I practiced:
- Infrastructure as Code overview
- Terraform HCL syntax
- Providers, resources, variables, outputs
- init, fmt, validate, plan, apply, output, destroy
EOT
}
