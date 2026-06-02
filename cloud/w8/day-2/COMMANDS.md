# W8-D2 / Day-B — Các câu lệnh đã sử dụng

Tập hợp toàn bộ các câu lệnh cần chạy để hoàn thành checklist Day 2.

## 1. Kiểm tra các công cụ cơ bản
```bash
# Kiểm tra phiên bản Docker
docker --version

# Kiểm tra Docker Daemon hoạt động
docker ps

# Kiểm tra phiên bản kubectl client
kubectl version --client

# Kiểm tra phiên bản minikube
minikube version
```

## 2. Quản lý cụm Kubernetes với Minikube
```bash
# Khởi động cụm minikube sử dụng driver Docker
minikube start --driver=docker

# Kiểm tra thông tin cụm (Cluster Info)
kubectl cluster-info

# Kiểm tra danh sách các Node hoạt động
kubectl get nodes
```

## 3. Triển khai tài nguyên lên Cluster
```bash
# Đổi thư mục làm việc về cloud/w8/day-2
cd cloud/w8/day-2

# Áp dụng cấu hình Deployment (nginx)
kubectl apply -f manifests/deployment.yaml

# Áp dụng cấu hình Service (NodePort)
kubectl apply -f manifests/service.yaml
```

## 4. Kiểm tra trạng thái tài nguyên
```bash
# Xem danh sách Pods đang chạy
kubectl get pods

# Xem chi tiết Deployment
kubectl get deployments

# Xem thông tin Service cùng cổng NodePort
kubectl get svc

# Xem log hoạt động của Pod mẫu
kubectl logs -l app=w8-day-2-nginx
```

## 5. Kiểm thử & Truy cập dịch vụ
```bash
# Khởi chạy Service và lấy URL truy cập trên trình duyệt
minikube service w8-day-2-nginx-service --url
```

## 6. Dọn dẹp môi trường (Cleanup)
```bash
# Xóa Service và Deployment
kubectl delete -f manifests/service.yaml
kubectl delete -f manifests/deployment.yaml

# Dừng cụm minikube
minikube stop
```
