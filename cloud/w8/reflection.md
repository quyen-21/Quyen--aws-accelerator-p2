# W8 Reflection

## W8-D1 — Terraform IaC overview + HCL syntax

### What I learned

- IaC là cách quản lý hạ tầng bằng code thay vì thao tác tay trên console.
- Terraform dùng file `.tf` để mô tả trạng thái mong muốn của hạ tầng.
- Provider là plugin giúp Terraform nói chuyện với nền tảng bên ngoài, ví dụ AWS, Kubernetes, Docker, Local.
- Resource là đối tượng Terraform quản lý, ví dụ EC2 instance, S3 bucket, local file.
- Variable giúp code linh hoạt hơn.
- Output giúp in thông tin quan trọng sau khi apply.

### What I practiced

- Tạo cấu trúc thư mục Phase 2.
- Viết Terraform cơ bản với `versions.tf`, `main.tf`, `variables.tf`, `outputs.tf`.
- Chạy workflow: `init`, `fmt`, `validate`, `plan`, `apply`, `output`, `destroy`.

### Problems I met

- Không gặp bất kỳ lỗi nào trong quá trình thực hiện. Các lệnh chạy hoàn toàn ổn định và trơn tru.

### How I solved them

- Không cần xử lý lỗi do Terraform đã được cấu hình và cài đặt đúng trên hệ thống, và cấu hình HCL của bài học chuẩn xác.

### Evidence

#### 1. `terraform init`
```text
Initializing provider plugins found in the configuration...
- Finding hashicorp/local versions matching "~> 2.5"...
- Finding hashicorp/random versions matching "~> 3.6"...
- Installing hashicorp/local v2.9.0...
- Installed hashicorp/local v2.9.0 (signed by HashiCorp)
- Installing hashicorp/random v3.9.0...
- Installed hashicorp/random v3.9.0 (signed by HashiCorp)

Initializing the backend...

Terraform has been successfully initialized!
```

#### 2. `terraform fmt`
```text
(Hoàn thành không có lỗi, mã nguồn đã được định dạng chuẩn xác)
```

#### 3. `terraform validate`
```text
Success! The configuration is valid.
```

#### 4. `terraform plan`
```text
Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + evidence_file_path = "./generated/w8-d1-hello.txt"
  + evidence_id        = (known after apply)
```

#### 5. `terraform apply`
```text
random_pet.evidence_suffix: Creating...
random_pet.evidence_suffix: Creation complete after 0s [id=bright-cow]
local_file.w8_d1_evidence: Creating...
local_file.w8_d1_evidence: Creation complete after 0s [id=dd7267807e58d708d9fe08c646604fbb9cf030d0]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

evidence_file_path = "./generated/w8-d1-hello.txt"
evidence_id = "bright-cow"
```

#### 6. `terraform output`
```text
evidence_file_path = "./generated/w8-d1-hello.txt"
evidence_id = "bright-cow"
```

#### 7. `terraform destroy`
```text
Plan: 0 to add, 0 to change, 2 to destroy.

Changes to Outputs:
  - evidence_file_path = "./generated/w8-d1-hello.txt" -> null
  - evidence_id        = "bright-cow" -> null
local_file.w8_d1_evidence: Destroying... [id=dd7267807e58d708d9fe08c646604fbb9cf030d0]
local_file.w8_d1_evidence: Destruction complete after 0s
random_pet.evidence_suffix: Destroying... [id=bright-cow]
random_pet.evidence_suffix: Destruction complete after 0s

Destroy complete! Resources: 2 destroyed.
```

