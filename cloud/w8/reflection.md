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

## W8-D2 - Kubernetes Container/Orchestration

### What I learned
- Docker image is a package of application and runtime.
- Container is a running instance of an image.
- Kubernetes manages containers through Pods.
- Deployment manages replicas and rolling updates.
- Service exposes Pods with a stable endpoint.

### What I practiced
- Checked Docker, kubectl, and minikube installation.
- Started a local Kubernetes cluster using minikube.
- Deployed nginx using a Kubernetes Deployment.
- Exposed nginx using a Service.
- Checked Pods, Deployments, and Services with kubectl.

### Problems I met
- Ban đầu dịch vụ nền Docker Desktop `com.docker.service` bị dừng trên máy Windows và không thể khởi chạy trực tiếp từ PowerShell nếu không có quyền Administrator.
- Lệnh khởi động Minikube (`minikube start`) yêu cầu kéo tải kicbase image (520MB) nên mất khoảng vài phút tùy thuộc đường truyền mạng.

### How I solved them
- Đã cài đặt thành công `minikube` thông qua `winget`.
- Nhờ người dùng bật ứng dụng GUI Docker Desktop thủ công để Docker Engine hoạt động ổn định.
- Chờ kéo tải thành công các thành phần Kubernetes và Nginx image.

### Evidence
- Kiểm tra phiên bản các công cụ cơ bản:
```text
$ docker --version
Docker version 28.5.1, build e180ab8

$ kubectl version --client
Client Version: v1.34.1
Kustomize Version: v5.7.1

$ minikube version
minikube version: v1.38.1
commit: c93a4cb9311efc66b90d33ea03f75f2c4120e9b0
```

- Khởi động Minikube và kiểm tra Cluster:
```text
$ minikube start --driver=docker
* minikube v1.38.1 on Microsoft Windows 11 Home Single Language 24H2
* Using Docker Desktop driver with root privileges
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.50 ...
* Downloading Kubernetes v1.35.1 preload ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

$ kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   41s   v1.35.1
```

- Triển khai manifests (Deployment & Service) và kiểm tra trạng thái Pods/Service:
```text
$ kubectl apply -f manifests/deployment.yaml
deployment.apps/w8-day-2-nginx created

$ kubectl apply -f manifests/service.yaml
service/w8-day-2-nginx-service created

$ kubectl get deployments
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
w8-day-2-nginx   2/2     2            2           59s

$ kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
w8-day-2-nginx-6bff485b56-4k2wx   1/1     Running   0          59s
w8-day-2-nginx-6bff485b56-n5kw9   1/1     Running   0          59s

$ kubectl get svc
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes               ClusterIP   10.96.0.1       <none>        443/TCP        101s
w8-day-2-nginx-service   NodePort    10.107.152.50   <none>        80:31231/TCP   58s
```

- Kiểm thử truy cập Service (Minikube tunnel URL):
```text
$ minikube service w8-day-2-nginx-service --url
http://127.0.0.1:53257

(Kiểm thử thành công, ứng dụng trả về trang chào mừng của Nginx)
```

- Kiểm tra logs của Pod:
```text
$ kubectl logs w8-day-2-nginx-6bff485b56-4k2wx
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
...
2026/06/02 04:46:58 [notice] 1#1: start worker processes
2026/06/02 04:46:58 [notice] 1#1: start worker process 29
...
```



