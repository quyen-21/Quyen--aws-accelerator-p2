# W9 Day 1 Checklist — GitOps & CI/CD

> Week 9 theme: **Deliver Smartly**  
> Day 1 topic: **GitOps & CI/CD**  
> Main goal: chuyển cách deploy từ `kubectl apply` thủ công sang GitOps-managed bằng Git + ArgoCD/GitHub Actions.

---

## 1. Mục tiêu cuối Day 1

Sau Day 1, cần chứng minh được:

- [ ] Manifest Kubernetes của app W8 được lưu trong Git repository.
- [ ] Không chỉnh sửa trực tiếp trong cluster bằng `kubectl apply` cho luồng deploy chính.
- [ ] ArgoCD theo dõi repo Git và tự đồng bộ trạng thái vào Kubernetes cluster.
- [ ] GitHub Actions chạy kiểm tra khi có Pull Request hoặc push.
- [ ] Hiểu được rollback đúng theo GitOps bằng `git revert`.
- [ ] Có bằng chứng: screenshot GitHub Actions pass, ArgoCD app `Synced/Healthy`, commit history.

---

## 2. Kiến thức cần nắm

### 2.1 GitOps là gì?

- [ ] GitOps là mô hình vận hành trong đó Git là **source of truth**.
- [ ] Toàn bộ trạng thái mong muốn của hệ thống được mô tả bằng YAML/manifest trong Git.
- [ ] Cluster Kubernetes chỉ là nơi chạy trạng thái thực tế.
- [ ] Công cụ như ArgoCD/Flux sẽ so sánh trạng thái trong Git với trạng thái trong cluster.
- [ ] Nếu cluster khác Git, GitOps controller sẽ sync để cluster quay về đúng trạng thái mong muốn.

Ghi nhớ nhanh:

```text
Git = desired state
Cluster = actual state
ArgoCD = sync engine
```

---

### 2.2 CI/CD trong Day 1

- [ ] CI là kiểm tra chất lượng code/manifest trước khi merge.
- [ ] CD là triển khai thay đổi sau khi code/manifest đã merge.
- [ ] Với Day 1, GitHub Actions nên làm phần kiểm tra.
- [ ] ArgoCD nên làm phần deploy/sync vào Kubernetes.

Luồng đề xuất:

```text
Developer sửa YAML
        ↓
Commit + push
        ↓
Pull Request
        ↓
GitHub Actions validate YAML
        ↓
Merge vào main
        ↓
ArgoCD phát hiện thay đổi
        ↓
ArgoCD sync vào cluster
```

---

### 2.3 ArgoCD cần hiểu gì?

- [ ] ArgoCD là công cụ Continuous Delivery cho Kubernetes.
- [ ] ArgoCD hoạt động theo mô hình pull-based: cluster tự kéo cấu hình từ Git.
- [ ] ArgoCD Application mô tả:
  - repo Git nằm ở đâu
  - path manifest nào cần sync
  - namespace đích là gì
  - sync policy là manual hay automatic
- [ ] Trạng thái quan trọng trong ArgoCD:
  - `Synced`: trạng thái trong cluster giống Git
  - `OutOfSync`: cluster khác Git
  - `Healthy`: resource chạy ổn
  - `Degraded`: resource lỗi

---

### 2.4 ArgoCD vs Flux

- [ ] ArgoCD có UI trực quan, dễ demo lab.
- [ ] Flux cũng là GitOps tool nhưng thiên về CLI/YAML nhiều hơn.
- [ ] Với W9 Day 1, ưu tiên dùng ArgoCD để dễ show-and-tell.

---

### 2.5 App of Apps

- [ ] App of Apps là pattern dùng một ArgoCD Application cha để quản lý nhiều Application con.
- [ ] Phù hợp khi hệ thống có nhiều thành phần: frontend, backend, database, observability, rollout.
- [ ] Root app giúp quản lý tập trung toàn bộ platform.

Ví dụ ý tưởng:

```text
root-app
  ├── frontend-app
  ├── backend-app
  ├── database-app
  └── observability-app
```

---

### 2.6 Sync waves

- [ ] Sync waves dùng để điều khiển thứ tự apply resource trong ArgoCD.
- [ ] Resource quan trọng hoặc phụ thuộc nên được apply trước.
- [ ] CRD nên có trước Custom Resource.
- [ ] Namespace nên có trước Deployment/Service.

Gợi ý thứ tự:

```text
wave -1: Namespace
wave  0: ConfigMap, Secret
wave  1: Service
wave  2: Deployment/Rollout
wave  3: Ingress
wave  4: Monitoring rules/Dashboard
```

Ví dụ annotation:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
```

---

### 2.7 Rollback trong GitOps

- [ ] Rollback đúng GitOps nên dùng `git revert`.
- [ ] `kubectl rollout undo` chỉ nên dùng khi chữa cháy khẩn cấp.
- [ ] Nếu dùng `kubectl rollout undo` nhưng không sửa Git, ArgoCD có thể sync lại version lỗi từ Git.

Cách rollback đúng:

```bash
git log --oneline
git revert <bad_commit_sha>
git push origin main
```

Sau đó ArgoCD sẽ sync lại trạng thái cũ.

---

## 3. Checklist thực hành

### 3.1 Chuẩn bị repo

- [ ] Tạo thư mục Day 1:

```bash
mkdir -p cloud/w9/day-a/.github/workflows
mkdir -p cloud/w9/day-a/argocd
mkdir -p cloud/w9/day-a/manifests
```

- [ ] Đưa manifest Kubernetes từ W8 vào repo.
- [ ] Kiểm tra các file YAML có tên rõ ràng.
- [ ] Không để secret thật trong Git.
- [ ] Thêm README hoặc checklist giải thích cách chạy.

Cấu trúc đề xuất:

```text
cloud/w9/day-a/
  checklist.md
  manifests/
    namespace.yaml
    frontend.yaml
    backend.yaml
    service.yaml
  argocd/
    application.yaml
    root-app.yaml
  .github/
    workflows/
      validate-yaml.yml
```

---

### 3.2 Tạo workflow GitHub Actions

- [ ] Tạo file:

```text
.github/workflows/validate-yaml.yml
```

hoặc nếu muốn để riêng trong Day 1:

```text
cloud/w9/day-a/.github/workflows/validate-yaml.yml
```

Lưu ý: GitHub Actions chỉ tự chạy khi workflow nằm ở `.github/workflows/` tại root repo. Nếu để trong `cloud/w9/day-a/.github/workflows/`, file chỉ dùng để nộp minh chứng học tập, không tự trigger.

Nội dung workflow mẫu:

```yaml
name: Validate Kubernetes YAML

on:
  pull_request:
    paths:
      - "cloud/w9/day-a/**"
  push:
    branches:
      - main
    paths:
      - "cloud/w9/day-a/**"

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Validate YAML syntax
        run: |
          python - <<'PY'
          import os
          import yaml

          base = "cloud/w9/day-a"
          failed = False

          for root, _, files in os.walk(base):
              for file in files:
                  if file.endswith((".yaml", ".yml")):
                      path = os.path.join(root, file)
                      try:
                          with open(path, "r", encoding="utf-8") as f:
                              list(yaml.safe_load_all(f))
                          print(f"OK: {path}")
                      except Exception as e:
                          failed = True
                          print(f"ERROR: {path}: {e}")

          if failed:
              raise SystemExit(1)
          PY
```

- [ ] Commit workflow.
- [ ] Push lên GitHub.
- [ ] Mở Pull Request hoặc push vào branch để test workflow.
- [ ] Chụp screenshot workflow pass.

---

### 3.3 Cài ArgoCD trên minikube

- [ ] Tạo namespace cho ArgoCD:

```bash
kubectl create namespace argocd
```

- [ ] Cài ArgoCD:

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

- [ ] Kiểm tra pod:

```bash
kubectl get pods -n argocd
```

- [ ] Port-forward ArgoCD UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

- [ ] Lấy password admin ban đầu:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

- [ ] Truy cập UI:

```text
https://localhost:8080
```

---

### 3.4 Tạo ArgoCD Application

- [ ] Tạo file:

```text
cloud/w9/day-a/argocd/application.yaml
```

Mẫu Application:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: w9-day1-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/quyen-21/Quyen--aws-accelerator-p2.git
    targetRevision: main
    path: cloud/w9/day-a/manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: w9-day1
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

- [ ] Apply Application lần đầu:

```bash
kubectl apply -f cloud/w9/day-a/argocd/application.yaml
```

- [ ] Kiểm tra Application:

```bash
kubectl get applications -n argocd
```

- [ ] Mở ArgoCD UI kiểm tra app `Synced` và `Healthy`.
- [ ] Chụp screenshot trạng thái app.

---

### 3.5 Test GitOps sync

- [ ] Sửa một giá trị nhỏ trong manifest, ví dụ replicas:

```yaml
replicas: 2
```

thành:

```yaml
replicas: 3
```

- [ ] Commit thay đổi:

```bash
git add cloud/w9/day-a
git commit -m "[W9-D1] test argocd sync"
git push origin main
```

- [ ] Chờ ArgoCD tự sync hoặc bấm Sync trên UI.
- [ ] Kiểm tra Kubernetes:

```bash
kubectl get pods -n w9-day1
kubectl get deploy -n w9-day1
```

- [ ] Xác nhận số replica đã thay đổi.
- [ ] Chụp screenshot minh chứng.

---

### 3.6 Test rollback bằng Git

- [ ] Xem commit history:

```bash
git log --oneline
```

- [ ] Revert commit vừa thay đổi:

```bash
git revert <commit_sha>
git push origin main
```

- [ ] Kiểm tra ArgoCD sync lại trạng thái cũ.
- [ ] Kiểm tra Deployment/Pod trong cluster.
- [ ] Ghi nhận kết quả vào reflection.

---

## 4. Deliverables cần nộp Day 1

- [ ] Link repository GitHub.
- [ ] File checklist Day 1.
- [ ] File GitHub Actions workflow.
- [ ] File ArgoCD Application YAML.
- [ ] Manifest Kubernetes của app W8.
- [ ] Screenshot GitHub Actions pass.
- [ ] Screenshot ArgoCD app `Synced/Healthy`.
- [ ] Screenshot Kubernetes resource sau khi sync.
- [ ] Commit message đúng format `[W9-D1] <topic ngắn>`.
- [ ] Ghi reflection ngắn: đã làm gì, lỗi gì, sửa như thế nào.

---

## 5. Tiêu chí tự đánh giá

| Mức | Mô tả |
|---|---|
| Basic | Có manifest trong Git, có ArgoCD Application, sync được app |
| Good | Có GitHub Actions validate YAML, ArgoCD auto sync, có screenshot minh chứng |
| Excellent | Có App of Apps, sync waves, test rollback bằng `git revert`, reflection rõ ràng |

---

## 6. Lỗi thường gặp và cách xử lý

### Lỗi 1: ArgoCD app OutOfSync

Kiểm tra:

```bash
kubectl describe application w9-day1-app -n argocd
```

Nguyên nhân thường gặp:

- Sai `repoURL`.
- Sai `path` trong repo.
- Sai namespace.
- File YAML lỗi syntax.
- Repo private nhưng ArgoCD chưa có quyền truy cập.

---

### Lỗi 2: App không Healthy

Kiểm tra:

```bash
kubectl get pods -n w9-day1
kubectl describe pod <pod-name> -n w9-day1
kubectl logs <pod-name> -n w9-day1
```

Nguyên nhân thường gặp:

- Image sai tên hoặc sai tag.
- Container port không khớp Service.
- Pod thiếu resource.
- ConfigMap/Secret chưa được tạo.

---

### Lỗi 3: Workflow không chạy

Kiểm tra:

- Workflow có nằm đúng root `.github/workflows/` không?
- File có đuôi `.yml` hoặc `.yaml` không?
- Event `on:` có đúng branch/path không?
- Repo có bật GitHub Actions không?

---

## 7. Câu hỏi ôn Online Test Day 1

- [ ] GitOps là gì?
- [ ] Vì sao Git được gọi là source of truth?
- [ ] ArgoCD hoạt động theo cơ chế push hay pull?
- [ ] ArgoCD Application dùng để mô tả gì?
- [ ] `Synced`, `OutOfSync`, `Healthy`, `Degraded` nghĩa là gì?
- [ ] App of Apps dùng trong trường hợp nào?
- [ ] Sync waves giải quyết vấn đề gì?
- [ ] Vì sao rollback bằng `git revert` phù hợp GitOps hơn `kubectl rollout undo`?
- [ ] GitHub Actions trong Day 1 nên kiểm tra những gì?
- [ ] Vì sao không nên chỉnh sửa cluster trực tiếp bằng `kubectl apply` trong GitOps?

---

## 8. Reflection mẫu

Điền vào `cloud/w9/reflection.md` hoặc cuối file này:

```md
## W9 Day 1 Reflection

### Hôm nay em đã làm được
- ...

### Kiến thức em hiểu rõ hơn
- ...

### Lỗi em gặp
- ...

### Cách em sửa
- ...

### Bằng chứng
- GitHub Actions: ...
- ArgoCD Synced/Healthy: ...
- Commit: ...

### Cần cải thiện
- ...
```

---

## 9. Kết luận Day 1

Day 1 hoàn thành khi app W8 không còn phụ thuộc vào việc apply YAML thủ công. Thay vào đó, mọi thay đổi đi qua Git, được kiểm tra bằng GitHub Actions, rồi được ArgoCD đồng bộ vào Kubernetes cluster.

Câu nhớ nhanh:

```text
Commit lên Git → GitHub Actions kiểm tra → ArgoCD sync → Kubernetes chạy đúng trạng thái mong muốn.
```

---

# 4. GitHub Actions Workflow (PR Validation)

## Mục tiêu

Khi mở Pull Request:

```text
- Kiểm tra YAML hợp lệ
- Kiểm tra Kubernetes Manifest
- Không deploy thật
```

Khi Merge vào main:

```text
- ArgoCD tự sync
- Cluster cập nhật trạng thái mới
```

---

## Workflow kiểm tra Kubernetes YAML

Tạo file:

```bash
.github/workflows/validate-k8s.yaml
```

```yaml
name: Validate Kubernetes Manifests

on:
  pull_request:
    branches:
      - main

jobs:
  validate:

    runs-on: ubuntu-latest

    steps:

      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Install Kubeconform
        run: |
          curl -L \
          https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-amd64.tar.gz \
          | tar xz

      - name: Validate YAML
        run: |
          find . \
          \( -name "*.yaml" -o -name "*.yml" \) \
          -exec ./kubeconform {} \;
```

---

## Workflow kiểm tra Terraform

Nếu repo có Terraform:

```bash
.github/workflows/terraform-check.yaml
```

```yaml
name: Terraform Validation

on:
  pull_request:
    branches:
      - main

jobs:
  terraform:

    runs-on: ubuntu-latest

    steps:

      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate
```

---

# 5. Cài đặt ArgoCD trên Minikube

## Tạo Namespace

```bash
kubectl create namespace argocd
```

---

## Cài ArgoCD

```bash
kubectl apply \
-n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

## Kiểm tra Pod

```bash
kubectl get pods -n argocd
```

Kết quả mong đợi:

```text
argocd-server
argocd-repo-server
argocd-application-controller
argocd-dex-server
```

Tất cả trạng thái:

```text
Running
```

---

## Truy cập UI

```bash
kubectl port-forward svc/argocd-server \
-n argocd \
8080:443
```

Mở:

```text
https://localhost:8080
```

---

## Lấy mật khẩu Admin

```bash
kubectl -n argocd \
get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" \
| base64 -d
```

Username:

```text
admin
```

---

# 6. ArgoCD Application

## Mục tiêu

Quản lý toàn bộ ứng dụng W8 bằng Git.

```text
Git Repository
      ↓
   ArgoCD
      ↓
 Kubernetes
```

---

## Application YAML

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application

metadata:
  name: webapp

spec:
  project: default

  source:
    repoURL: https://github.com/<username>/<repo>.git
    targetRevision: main
    path: cloud/w8/manifests

  destination:
    server: https://kubernetes.default.svc
    namespace: default

  syncPolicy:

    automated:
      prune: true
      selfHeal: true

    syncOptions:
      - CreateNamespace=true
```

Áp dụng:

```bash
kubectl apply -f webapp.yaml
```

---

# 7. App of Apps Pattern

## Tại sao cần?

W9 có nhiều thành phần:

```text
Frontend
Backend
Monitoring
Rollout
Alert Rules
Dashboard
```

Nếu tạo từng Application sẽ rất khó quản lý.

Sử dụng:

```text
Root Application
        |
        +---- Frontend
        +---- Backend
        +---- Observability
        +---- Rollouts
```

---

## Root Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application

metadata:
  name: root-app

spec:
  project: default

  source:
    repoURL: https://github.com/<username>/<repo>.git
    targetRevision: main
    path: cloud/w9/apps

  destination:
    server: https://kubernetes.default.svc
    namespace: argocd

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## App Structure

```bash
cloud/
└── w9/
    └── apps/

        ├── frontend.yaml
        ├── backend.yaml
        ├── observability.yaml
        └── rollout.yaml
```

---

# 8. Sync Waves

## Vấn đề

Nếu Deployment được tạo trước Namespace:

```text
Deployment FAILED
```

Nếu Custom Resource được tạo trước CRD:

```text
FAILED
```

Cần có thứ tự triển khai.

---

## Namespace

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
```

---

## ConfigMap

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "0"
```

---

## Service

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
```

---

## Deployment

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "2"
```

---

## Dashboard / Monitoring

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "3"
```

---

## Thứ tự đề xuất cho W9

```text
Wave -1
Namespace

Wave 0
ConfigMap
Secret

Wave 1
Service

Wave 2
Deployment
Rollout

Wave 3
PrometheusRule

Wave 4
Grafana Dashboard
```

---

# 9. GitOps Flow End-to-End

## Luồng triển khai

```text
Developer
    |
    | Commit
    v

Git Repository
    |
    | Pull Request
    v

GitHub Actions
    |
    | Validate
    v

Merge Main
    |
    v

ArgoCD Detect Changes
    |
    v

Sync Cluster
    |
    v

Kubernetes Updated
```

---

## Ví dụ thực tế

Ban đầu:

```yaml
replicas: 2
```

Sửa:

```yaml
replicas: 3
```

Commit:

```bash
git add .
git commit -m "[W9-D1] scale frontend to 3 replicas"
git push
```

ArgoCD:

```text
OutOfSync
```

Sau vài giây:

```text
Synced
Healthy
```

Kubernetes:

```bash
kubectl get pods
```

Kết quả:

```text
frontend-xxxxx
frontend-yyyyy
frontend-zzzzz
```

---

# 10. GitOps Rollback

## Cách đúng trong GitOps

Tìm commit lỗi:

```bash
git log --oneline
```

Ví dụ:

```text
123abc deploy bad image
```

Rollback:

```bash
git revert 123abc
git push
```

---

## Điều gì xảy ra?

```text
Git cập nhật trạng thái cũ
        ↓
ArgoCD phát hiện thay đổi
        ↓
Cluster tự rollback
```

---

# Bằng chứng cần nộp Day A

```text
✅ Screenshot GitHub Actions PASS

✅ Screenshot ArgoCD Login

✅ Screenshot Application Synced

✅ Screenshot Application Healthy

✅ Screenshot Root App

✅ Screenshot Sync Wave Resources

✅ Screenshot Git Commit History

✅ Screenshot Git Revert Demo

✅ Commit:
   [W9-D1] add argocd application

✅ Commit:
   [W9-D1] add github actions validation
```

## Kết quả sau khi bổ sung

Day A của bạn sẽ bao gồm:

```text
1. GitOps
2. CI/CD
3. ArgoCD
4. GitHub Actions
5. ArgoCD Application
6. App of Apps
7. Sync Waves
8. GitOps Flow
9. GitOps Rollback
10. Evidence Checklist
```

=> Đủ để khớp với Day B (Observability) và Day C (Progressive Delivery) thành một bộ W9 hoàn chỉnh.

