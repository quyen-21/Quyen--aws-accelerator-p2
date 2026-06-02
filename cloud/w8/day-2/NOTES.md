# W8-D2 / Day-B — Lý thuyết Docker & Kubernetes

## 1. Kiến thức cốt lõi về Docker

Docker là một nền tảng mã nguồn mở giúp đơn giản hóa quy trình xây dựng (build), chia sẻ (share) và thực thi (run) các ứng dụng dưới dạng các **Container** độc lập. Nó giúp tách ứng dụng hoàn toàn khỏi hạ tầng phía dưới để đảm bảo ứng dụng chạy đồng nhất trên mọi môi trường (Local, Staging, Production).

### Các khái niệm Docker quan trọng:
- **Image (Ảnh đóng gói):** Là một template chỉ đọc (read-only) chứa mã nguồn ứng dụng, thư viện, biến môi trường và runtime cần thiết để ứng dụng chạy. Nó giống như bản thiết kế (blueprint) hoặc class trong OOP.
- **Container (Thực thể chạy):** Là một instance (thực thể) đang hoạt động được khởi tạo từ Docker Image. Nó chạy độc lập, được cô lập hóa với máy host và các container khác.
- **Dockerfile (Kịch bản xây dựng):** Một file văn bản chứa tập hợp các lệnh chỉ dẫn Docker cách build nên một Image.
- **Port Mapping (Ánh xạ cổng):** Cơ chế mở cổng từ Container ra máy Host để máy bên ngoài hoặc máy Host có thể truy cập được ứng dụng đang chạy bên trong Container (Ví dụ: `-p 8080:80`).
- **Registry:** Nơi lưu trữ và chia sẻ các Docker Images (ví dụ: Docker Hub, Amazon ECR, GitHub Packages).

---

## 2. Kiến thức cốt lõi về Kubernetes (K8s)

Kubernetes là một nền tảng mã nguồn mở mạnh mẽ chuyên dùng để điều phối, quản lý tự động hóa việc deploy, scaling và vận hành các container application trong một cụm máy chủ (Cluster).

### Các thành phần cốt lõi của Kubernetes:
- **Cluster:** Cụm các máy chủ (vật lý hoặc ảo) chạy Kubernetes, bao gồm một hoặc nhiều Control Plane (Master Node) điều khiển cụm và các Worker Nodes chạy workloads.
- **Node:** Một máy tính (ảo hoặc vật lý) trong Kubernetes Cluster. Có hai loại chính:
  - **Control Plane Node:** Điều khiển trạng thái mong muốn của cluster.
  - **Worker Node:** Chạy các ứng dụng container thực tế.
- **Pod:** Đơn vị tính toán nhỏ nhất có thể tạo và quản lý trong Kubernetes. Một Pod chứa một hoặc nhiều container chia sẻ chung không gian lưu trữ mạng (IP, Port) và tài nguyên.
- **Deployment:** Một tài nguyên giúp quản lý khai báo (declarative update) cho các Pods và ReplicaSets. Nó đảm bảo số lượng bản sao (Replicas) luôn đúng như thiết lập và hỗ trợ cập nhật ứng dụng không gây gián đoạn (Rolling Updates).
- **Service:** Một abstraction (trừu tượng hóa) để định nghĩa một tập hợp các Pods và chính sách truy cập chúng (endpoint ổn định). Do Pod có vòng đời ngắn và IP thay đổi liên tục, Service giúp cung cấp một DNS và IP cố định để kết nối.
- **Namespace:** Cơ chế phân vùng tài nguyên ảo trong một cluster vật lý, giúp phân chia dự án, môi trường (Dev, Staging, Prod) hoặc phân quyền người dùng.
- **kubectl:** CLI (Command Line Interface) chính thức để quản lý và điều khiển cụm Kubernetes từ máy cá nhân.
- **minikube:** Công cụ giúp dựng một cụm Kubernetes node đơn (Single-node cluster) gọn nhẹ ngay trên máy cá nhân để học tập và phát triển cục bộ.
