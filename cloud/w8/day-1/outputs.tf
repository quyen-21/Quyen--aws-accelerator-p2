output "evidence_file_path" {
  description = "Path to the generated W8-D1 evidence file."
  value       = local_file.w8_d1_evidence.filename
}

output "evidence_id" {
  description = "Random ID generated for this Terraform practice run."
  value       = random_pet.evidence_suffix.id
}
