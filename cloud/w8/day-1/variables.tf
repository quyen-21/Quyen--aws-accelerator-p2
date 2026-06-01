variable "student_name" {
  description = "Name of the student practicing Terraform."
  type        = string
  default     = "Quyen"
}

variable "course_name" {
  description = "Name of the course or phase."
  type        = string
  default     = "AWS Accelerator Phase 2 - Cloud/DevOps"
}

variable "day_code" {
  description = "Learning day code used in the generated evidence file."
  type        = string
  default     = "W8-D1"
}
