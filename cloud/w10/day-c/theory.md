# W10-Day C: Platform Integration, Runbook & Cost Guard

Tài liệu tóm tắt lý thuyết cốt lõi của **W10 - Day C** (Platform Integration, ResourceQuota, LimitRange, Chaos Testing, Incident Response và Cost Anomaly Detection).

---

## 1. Platform Integration (Tích hợp nền tảng)

### Ý tưởng cốt lõi
Platform Integration là việc liên kết tất cả các thành phần công nghệ đã học từ W8, W9 đến W10 thành một hệ thống đồng nhất tự động:
* **W8 (Foundation):** GitOps (ArgoCD), Observability (Prometheus, Grafana), Service Mesh (Linkerd/Istio).
* **W9 (Delivery):** Progressive Delivery (Argo Rollouts, Canary).
* **W10 (Security):** Phân quyền (RBAC), Secrets Management (ESO), Policy Enforcement (Gatekeeper).

### Mục tiêu vận hành (Platform Bootstrap)
* Xây dựng cấu trúc Git repo sao cho khi triển khai lên một **cluster trống hoàn toàn mới** (fresh cluster), nền tảng có thể tự động cài đặt và sẵn sàng hoạt động trong **dưới 2 giờ**.
* Toàn bộ cấu trúc được định nghĩa khai báo qua Git (GitOps). Tránh hoàn toàn việc cấu hình thủ công bằng tay.

---

## 2. Resource Management: ResourceQuota & LimitRange

Kubernetes là môi trường chia sẻ tài nguyên (multi-tenancy). Nếu một ứng dụng bị quá tải hoặc memory leak, nó có thể hút hết tài nguyên của Node, làm sập các ứng dụng khác. K8s cung cấp 2 công cụ để kiểm soát việc này:

### A. ResourceQuota (Giới hạn Namespace)
* **Khái niệm:** Đặt giới hạn **tổng dung lượng** tài nguyên (CPU, Memory, số lượng Pod, số lượng Service...) mà một Namespace được phép tiêu thụ.
* **Cách hoạt động:** Khi tổng lượng CPU/RAM của các Pod đang chạy trong Namespace đạt đến ngưỡng giới hạn, API Server sẽ từ chối tạo thêm Pod mới trong Namespace đó.
* **Ví dụ:** Namespace `dev` chỉ được dùng tối đa 4 Core CPU và 8GB RAM trên toàn bộ cluster.

### B. LimitRange (Thiết lập mặc định cho Container)
* **Khái niệm:** Đặt giới hạn và **giá trị mặc định** cho từng Pod hoặc Container riêng lẻ trong Namespace.
* **Tác dụng:**
  * **Default Request/Limit:** Nếu Developer deploy Pod mà quên khai báo thông số `resources.requests` và `resources.limits`, K8s sẽ tự động gán các giá trị mặc định được định nghĩa sẵn trong `LimitRange`.
  * **Min/Max limits:** Ràng buộc container không được cấu hình tài nguyên nhỏ hơn mức tối thiểu hoặc lớn hơn mức tối đa cho phép.
* **Ví dụ:** Nếu container không khai báo tài nguyên, tự động gán mặc định CPU request là `100m` và Memory request là `256Mi`.

---

## 3. Chaos Engineering (Kiểm thử độ bền)

* **Khái niệm:** Việc chủ động đưa các sự cố giả lập (tiêm lỗi - inject faults) vào hệ thống đang chạy trong môi trường staging/production để kiểm chứng khả năng tự phục hồi (resilience).
* **Mục tiêu:** Kiểm tra xem:
  * Ứng dụng có tự động chuyển đổi dự phòng (failover) không?
  * Hệ thống giám sát (Prometheus/Grafana) có phát hiện lỗi và gửi cảnh báo đúng lúc không?
  * Hệ thống tự động phục hồi (auto-healing) của K8s có hoạt động hiệu quả không?
* **Công cụ phổ biến:** Chaos Mesh, LitmusChaos.
* **Các kịch bản phổ biến:** Kill Pod ngẫu nhiên, làm nghẽn/chậm mạng (network latency), giả lập đĩa cứng bị đầy.

---

## 4. Incident Response (IR) & Runbooks

Khi xảy ra sự cố bảo mật hoặc kỹ thuật trên Cluster, đội ngũ vận hành cần hành động theo quy trình chuẩn thay vì tự phán đoán.

### A. Runbook là gì?
* Là tài liệu hướng dẫn chuẩn (SOP) ghi rõ các bước chi tiết cần làm khi một cảnh báo cụ thể xuất hiện.
* *Ví dụ:* Runbook xử lý lỗi "Database Connection Failed", Runbook xử lý lỗi "Disk Space Low".

### B. Quy trình ứng phó sự cố 6 bước (Incident Response Playbook)
1. **Detect (Phát hiện):** Phát hiện sự cố qua cảnh báo Prometheus/Grafana hoặc phát hiện bất thường từ AWS GuardDuty.
2. **Triage (Đánh giá):** Xác định mức độ nghiêm trọng và phạm vi ảnh hưởng (Ví dụ: có ảnh hưởng đến người dùng cuối không?).
3. **Contain (Cô lập):** Ngăn chặn sự cố lan rộng. **(Bước quan trọng nhất khi bị hack)**.
   * *Khi 1 Pod bị compromise (bị hack):*
     * Áp dụng `NetworkPolicy` chặn toàn bộ traffic mạng ra/vào Pod đó.
     * Gỡ nhãn (Label) của Pod đó để hệ thống rút nó khỏi `Service`, ngăn không cho traffic của khách hàng đi vào Pod bị hack này. (Pod vẫn chạy phục vụ việc điều tra nguyên nhân nhưng không ảnh hưởng tới người dùng).
   * *Khi 1 Node bị compromise:*
     * Chạy lệnh `kubectl cordon` để chặn không cho Pod mới deploy lên Node bị lỗi.
     * Chạy `kubectl drain` để di chuyển các Pod sạch sang Node khác một cách an toàn.
     * Snapshot đĩa cứng EBS của Node đó để giữ lại dữ liệu phục vụ điều tra nguyên nhân (forensics).
4. **Eradicate (Loại bỏ):** Xóa bỏ tài nguyên bị lỗi/mã độc, thu hồi và xoay vòng (rotate) các secrets bị lộ, vá lỗ hổng bảo mật.
5. **Recover (Khôi phục):** Deploy lại phiên bản ứng dụng an toàn từ GitOps, kiểm tra hệ thống hoạt động bình thường.
6. **Post-mortem (Rút kinh nghiệm):** Viết báo cáo phân tích nguyên nhân gốc rễ (RCA) và đưa ra hành động khắc phục lâu dài để tránh lặp lại sự cố.

---

## 5. AWS Cost Anomaly Detection (Quản lý chi phí)

* **Khái niệm:** Dịch vụ của AWS sử dụng học máy (Machine Learning) để theo dõi lịch sử chi tiêu của tài khoản và tự động phát hiện các biến động chi phí bất thường.
* **Lợi ích:**
  * Phát hiện ngay lập tức nếu có rò rỉ chi phí do cấu hình sai tài nguyên (ví dụ: tạo ổ đĩa EBS quá lớn nhưng không dùng).
  * Phát hiện sự cố bảo mật: Nếu tài khoản bị hacker xâm nhập tạo hàng loạt EC2 cấu hình khủng để đào coin, hệ thống sẽ cảnh báo ngay.
  * Tự động gửi thông báo trực tiếp qua Email hoặc Slack (thông qua Amazon EventBridge và SNS).