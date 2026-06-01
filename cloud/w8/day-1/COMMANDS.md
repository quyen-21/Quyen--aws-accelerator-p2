# W8-D1 Terraform Commands

Chạy trong thư mục này:

```bash
cd cloud/w8/day-a
```

## 1. Kiểm tra version

```bash
terraform -version
```

## 2. Khởi tạo Terraform

```bash
terraform init
```

## 3. Format code

```bash
terraform fmt
```

## 4. Validate cấu hình

```bash
terraform validate
```

## 5. Xem trước thay đổi

```bash
terraform plan
```

## 6. Apply

```bash
terraform apply
```

Nhập `yes` khi Terraform hỏi xác nhận.

## 7. Xem output

```bash
terraform output
```

## 8. Kiểm tra file đã tạo

Windows PowerShell:

```powershell
Get-Content .\generated\w8-d1-hello.txt
```

Git Bash / macOS / Linux:

```bash
cat generated/w8-d1-hello.txt
```

## 9. Destroy

```bash
terraform destroy
```

Nhập `yes` khi Terraform hỏi xác nhận.

## 10. Commit

```bash
git add .
git commit -m "[W8-D1] terraform iac overview and hcl basics"
git push origin main
```
