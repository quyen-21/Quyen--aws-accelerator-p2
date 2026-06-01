# Phase 2 Cloud/DevOps Portfolio

Repo mẫu cho Phase 2 — Track Cloud/DevOps.

## Mục tiêu repo

Repo này dùng để lưu toàn bộ evidence học tập Phase 2:

- Code Terraform / Kubernetes / GitOps / Observability / Security
- Log command đã chạy
- Screenshot kết quả
- Reflection theo tuần
- Capstone W11–W12

## Cấu trúc thư mục

```text
cloud/
  w8/
    day-a/      # Terraform: IaC overview + HCL syntax
    day-b/      # Kubernetes: Container/Orchestration
    day-c/      # Kubernetes: Scaling + Networking
    lab/        # Mini K8s platform trên minikube
    reflection.md
  w9/
  w10/
capstone/
  w11/
  w12/
```

## Quy tắc commit

Format commit message:

```bash
git commit -m "[W8-D1] terraform iac overview and hcl basics"
```

Một số ví dụ:

```bash
git commit -m "[W8-D1] add terraform local file exercise"
git commit -m "[W8-D1] add terraform notes and reflection"
```

## Cách dùng nhanh

```bash
cd cloud/w8/day-a
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```

Bài tập trong `cloud/w8/day-a` dùng provider `local` và `random`, không tạo tài nguyên AWS nên phù hợp để luyện Terraform ngày đầu.
