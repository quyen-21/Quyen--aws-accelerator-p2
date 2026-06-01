# W8-D1 — Terraform IaC Overview + HCL Syntax

Ngày: 01/06/2026

## Checklist bắt buộc

- [x] Tạo cấu trúc thư mục Phase 2
- [x] Học Terraform IaC overview
- [x] Học HCL syntax
- [x] Làm bài tập Terraform cơ bản
- [ ] Commit với format `[W8-D1] ...`

## 1. IaC là gì?

IaC = Infrastructure as Code.

Thay vì tạo server, network, database bằng tay trên AWS Console, ta viết cấu hình bằng code. Terraform đọc code đó và tạo hạ tầng theo trạng thái mong muốn.

Ví dụ tư duy:

```text
Mình muốn có 1 file local tên hello.txt
Nội dung file lấy từ biến message
Terraform sẽ tạo đúng file đó cho mình
```

Trong thực tế cloud:

```text
Mình muốn có VPC, subnet, EC2, security group
Terraform sẽ gọi API AWS để tạo các resource đó
```

## 2. Terraform dùng để làm gì?

Terraform giúp:

- Khai báo hạ tầng bằng file `.tf`
- Tạo, sửa, xoá hạ tầng có kiểm soát
- Xem trước thay đổi bằng `terraform plan`
- Lưu trạng thái hạ tầng trong state file
- Tái sử dụng code qua module
- Làm việc nhóm dễ hơn vì hạ tầng được quản lý bằng Git

## 3. Các khái niệm cốt lõi

| Khái niệm | Hiểu đơn giản |
|---|---|
| Provider | Plugin để Terraform kết nối với nền tảng, ví dụ AWS, Docker, Local |
| Resource | Tài nguyên Terraform quản lý, ví dụ file, EC2, S3 |
| Variable | Biến đầu vào giúp cấu hình linh hoạt |
| Output | Giá trị in ra sau khi apply |
| State | File lưu trạng thái tài nguyên Terraform đang quản lý |
| Plan | Bản xem trước Terraform sẽ tạo/sửa/xoá gì |
| Apply | Thực thi thay đổi |
| Destroy | Xoá tài nguyên Terraform đang quản lý |

## 4. HCL syntax cơ bản

Terraform dùng ngôn ngữ cấu hình HCL.

### Block

```hcl
resource "local_file" "hello" {
  filename = "generated/hello.txt"
  content  = "Hello Terraform"
}
```

Trong đó:

- `resource` là loại block
- `local_file` là loại resource
- `hello` là tên local trong Terraform
- `{ ... }` chứa các arguments

### Argument

```hcl
filename = "generated/hello.txt"
content  = "Hello Terraform"
```

Argument có dạng:

```hcl
key = value
```

### Variable

```hcl
variable "student_name" {
  type        = string
  description = "Student name"
  default     = "Quyen"
}
```

Dùng variable:

```hcl
content = "Hello ${var.student_name}"
```

### Output

```hcl
output "file_path" {
  description = "Path of generated file"
  value       = local_file.hello.filename
}
```

## 5. Terraform workflow

Chạy trong thư mục `cloud/w8/day-a`:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```

Ý nghĩa:

| Command | Ý nghĩa |
|---|---|
| `terraform init` | Khởi tạo project, tải provider |
| `terraform fmt` | Format code `.tf` |
| `terraform validate` | Kiểm tra syntax/config hợp lệ |
| `terraform plan` | Xem trước thay đổi |
| `terraform apply` | Tạo/sửa tài nguyên |
| `terraform output` | Xem output |
| `terraform destroy` | Xoá tài nguyên đã tạo |

## 6. Bài tập thực hành

Bài này tạo một file local trong thư mục `generated/`.

Sau khi `terraform apply`, bạn sẽ thấy file:

```text
generated/w8-d1-hello.txt
```

Nội dung file được sinh từ variable và random pet name.

## 7. Evidence cần chụp hoặc lưu lại

Nên chụp màn hình hoặc copy log của các lệnh:

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```

Sau đó cập nhật vào:

```text
cloud/w8/reflection.md
```

## 8. Commit cuối ngày

```bash
git add .
git commit -m "[W8-D1] terraform iac overview and hcl basics"
git push origin main
```
