# W8-D2 / Day-B — Kubernetes Container & Orchestration

Ngày: 02/06/2026

## Giới thiệu bài học
Hôm nay chúng ta tìm hiểu về Docker và Kubernetes (K8s) nền tảng. Chúng ta sẽ thực hành đóng gói ứng dụng bằng container, chạy ứng dụng bằng Pod, quản lý nhân bản bằng Deployment, và cấu hình Service để expose ứng dụng ra bên ngoài.

---

## 1. Mục tiêu bài học
- [x] Tạo cấu trúc thư mục đúng chuẩn `cloud/w8/day-2/`.
- [x] Học tổng quan về Docker (Image, Container, Dockerfile, Port mapping).
- [x] Cài đặt & kiểm tra Docker Desktop.
- [x] Học tổng quan về Kubernetes (Cluster, Node, Pod, Deployment, Service, Namespace, kubectl, minikube).
- [x] Cài đặt & kiểm tra `kubectl` và `minikube`.
- [x] Khởi chạy Minikube cluster local (`minikube start`).
- [x] Viết file cấu hình `deployment.yaml` để triển khai ứng dụng Nginx mẫu.
- [x] Viết file cấu hình `service.yaml` dưới dạng NodePort để expose dịch vụ.
- [x] Kiểm tra trạng thái Pods, Deployments và Services bằng `kubectl`.
- [x] Lưu trữ logs và bằng chứng thực hành (Evidence).
- [x] Commit và push mã nguồn với định dạng `[W8-D2] ...`.

---

## 2. Cấu trúc thư mục học tập
```text
cloud/
  w8/
    day-2/
      README.md
      NOTES.md
      COMMANDS.md
      manifests/
        deployment.yaml
        service.yaml
      evidence/
        screenshots/
        logs/
```

---

## 3. Hướng dẫn thực hành nhanh
1. Khởi chạy Docker Desktop trên máy tính.
2. Khởi chạy Minikube cluster:
   ```bash
   minikube start --driver=docker
   ```
3. Triển khai tài nguyên lên Kubernetes:
   ```bash
   kubectl apply -f manifests/deployment.yaml
   kubectl apply -f manifests/service.yaml
   ```
4. Kiểm tra trạng thái:
   ```bash
   kubectl get pods
   kubectl get deployments
   kubectl get svc
   ```
5. Truy cập ứng dụng qua Minikube Service:
   ```bash
   minikube service w8-day-2-nginx-service
   ```
6. Dọn dẹp tài nguyên sau khi kiểm tra xong:
   ```bash
   kubectl delete -f manifests/service.yaml
   kubectl delete -f manifests/deployment.yaml
   ```
