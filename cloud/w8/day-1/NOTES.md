# W8-D1 Notes — Terraform IaC + HCL

## IaC overview

Infrastructure as Code nghĩa là hạ tầng được mô tả bằng code. Code này có thể lưu trên Git, review, tái sử dụng và chạy lại.

Ví dụ không dùng IaC:

1. Vào AWS Console.
2. Tạo EC2 bằng tay.
3. Tạo Security Group bằng tay.
4. Sau vài ngày khó nhớ đã cấu hình gì.

Ví dụ dùng IaC:

1. Viết `main.tf`.
2. Chạy `terraform plan` để xem Terraform sẽ làm gì.
3. Chạy `terraform apply` để tạo hạ tầng.
4. Người khác clone repo có thể hiểu và tái tạo môi trường.

## Terraform workflow dễ nhớ

```text
Write -> Init -> Plan -> Apply -> Observe -> Change -> Plan -> Apply -> Destroy
```

## File Terraform thường gặp

| File | Vai trò |
|---|---|
| `versions.tf` | Khai báo Terraform version và provider version |
| `main.tf` | Khai báo resource chính |
| `variables.tf` | Khai báo input variables |
| `outputs.tf` | Khai báo output values |
| `terraform.tfvars` | Gán giá trị biến, không nên commit nếu có dữ liệu nhạy cảm |

## HCL syntax quan trọng

### String

```hcl
name = "demo"
```

### Number

```hcl
instance_count = 2
```

### Boolean

```hcl
enabled = true
```

### List

```hcl
availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]
```

### Map

```hcl
tags = {
  Environment = "dev"
  Owner       = "Quyen"
}
```

### Reference

```hcl
value = local_file.w8_d1_evidence.filename
```

### Variable reference

```hcl
value = var.student_name
```

### Interpolation

```hcl
content = "Hello ${var.student_name}"
```

## Best practices cho ngày đầu

- Luôn chạy `terraform fmt` trước khi commit.
- Luôn chạy `terraform validate` để kiểm tra cấu hình.
- Luôn đọc kỹ `terraform plan` trước khi `apply`.
- Không commit `.tfstate`, `.terraform/`, file `.tfvars` chứa thông tin nhạy cảm.
- Không chạy `apply` trên AWS nếu chưa hiểu tài nguyên đó có tốn phí không.
