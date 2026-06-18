## 📌 PHẦN A: Phân Quyền (RBAC) & Admission Policy

### 1. Kubernetes RBAC (Phân quyền theo vai trò)
Hiểu đơn giản, RBAC trả lời câu hỏi: **"AI được phép làm GÌ trên tài nguyên NÀO?"**

*   **Role & ClusterRole (Bản phân quyền):** Định nghĩa danh sách các hành động (verbs: `get`, `list`, `create`, `delete`...) được phép thực hiện trên các đối tượng (resources: `pods`, `deployments`, `services`...).
*   **RoleBinding & ClusterRoleBinding (Lệnh gán quyền):** Gán bản phân quyền trên cho một đối tượng cụ thể (User, Group, ServiceAccount).

#### ⚖️ So sánh nhanh: Role vs ClusterRole & Binding

| Khái niệm | Phạm vi (Scope) | Ví dụ thực tế |
| :--- | :--- | :--- |
| **Role** | Chỉ trong **1 Namespace** | Cấp quyền đọc Pods chỉ trong namespace `development`. |
| **ClusterRole** | Toàn bộ **Cluster** | Cấp quyền quản lý Nodes, Namespaces (tài nguyên không thuộc namespace nào). |
| **RoleBinding** | Gán quyền trong **1 Namespace** | Chỉ cho phép User A đọc Pods của namespace `development`. |
| **ClusterRoleBinding** | Gán quyền toàn **Cluster** | Cho phép User A đọc Pods của tất cả các namespace trong cluster. |

> 💡 **Mẹo thiết kế:** Có thể dùng **ClusterRole** để định nghĩa quyền mẫu (ví dụ: `view-only`), sau đó dùng **RoleBinding** để gán vào từng namespace cụ thể. Giúp giảm thiểu trùng lặp code YAML.

---

### 2. ServiceAccount (SA)
*   **User/Group:** Dùng cho **con người** (Dev, Admin) đăng nhập vào Cluster qua AWS IAM, OIDC.
*   **ServiceAccount:** Dùng cho **máy/ứng dụng** (ví dụ: Pod chạy Jenkins cần gọi API K8s để tạo Pod khác). Mỗi Pod sẽ mang một danh tính ServiceAccount để làm việc với API Server.

---

### 3. Admission Controller (Chốt chặn API)
Là chốt chặn kiểm duyệt các yêu cầu (API Requests) gửi tới API Server trước khi ghi dữ liệu vào cơ sở dữ liệu `etcd`.

```
[API Request] ➔ [1. Mutating Webhook] ➔ [Kiểm tra Schema] ➔ [2. Validating Webhook] ➔ [etcd]
```

*   **Mutating Webhook (Chỉnh sửa):** Tự động chỉnh sửa/bổ sung cấu hình (Ví dụ: tự động chèn thêm container log/sidecar vào Pod khi deploy).
*   **Validating Webhook (Xác thực):** Kiểm tra tính hợp lệ và ra quyết định **Cho phép** hoặc **Từ chối (Deny)**. Không được sửa đổi dữ liệu (Ví dụ: chặn không cho deploy Pod nếu không có nhãn `env`).

---

### 4. OPA Gatekeeper (Bộ quản lý chính sách bằng Code)
Giúp định nghĩa các quy tắc bảo mật tùy biến cho Cluster sử dụng ngôn ngữ khai báo **Rego**.

*   **ConstraintTemplate (Khuôn mẫu):** Định nghĩa logic kiểm tra viết bằng mã Rego (ví dụ: kiểm tra xem tài nguyên có vượt số replica cho phép không).
*   **Constraint (Áp dụng cụ thể):** Gọi Template ở trên và điền tham số cụ thể (ví dụ: áp dụng quy tắc giới hạn replica cho Namespace `production`).

#### ⚙️ Cú pháp Rego & Liên kết Template - Constraint (Ví dụ tối giản)

*   **ConstraintTemplate (Viết logic kiểm tra bằng Rego):**
    ```rego
    violation[{"msg": msg}] {
      replicas := input.review.object.spec.replicas
      replicas > 5
      msg := sprintf("Số lượng replica (%v) vượt quá giới hạn tối đa là 5", [replicas])
    }
    ```
*   **Constraint (YAML cấu hình áp dụng):**
    ```yaml
    apiVersion: constraints.gatekeeper.sh/v1beta1
    kind: K8sMaxReplicas
    metadata:
      name: limit-replicas-to-5
    spec:
      match:
        kinds:
          - apiGroups: ["apps"]
            kinds: ["Deployment"]
    ```

---

## 📌 PHẦN B: Secrets Rotation & Supply Chain Security

### 1. Secrets Rotation với External Secrets Operator (ESO)
*   **Vấn đề:** Lưu Secret trực tiếp trên Git (GitOps) rất dễ bị lộ. Lưu dưới dạng K8s Secret thông thường thì chỉ mã hóa Base64 sơ sài và khó cập nhật khi mật khẩu thay đổi.
*   **Giải pháp (ESO):** Tự động đồng bộ Secret từ các kho lưu trữ bảo mật (như **AWS Secrets Manager**) về thành K8s Secret.

```
[AWS Secrets Manager] ➔ (Đồng bộ tự động qua ESO) ➔ [K8s Secret] ➔ [Pod đọc dùng]
```

*   **Xác thực qua IRSA (IAM Roles for Service Accounts):** Không lưu Access Key/Secret Key của AWS trong K8s. Thay vào đó, gán trực tiếp IAM Role của AWS cho ServiceAccount của ESO để phân quyền an toàn.
*   **SecretStore vs ExternalSecret:**
    *   `SecretStore`: Cấu hình cách kết nối tới AWS Secrets Manager (vùng miền nào, dùng IAM Role nào).
    *   `ExternalSecret`: Định nghĩa cụ thể cần kéo secret nào về và tần suất cập nhật (`refreshInterval` - ví dụ: mỗi 60 giây).

#### 🔄 Cách liên kết SecretStore & ExternalSecret

1.  **SecretStore (Khai báo kết nối tới AWS Secrets Manager):**
    ```yaml
    apiVersion: external-secrets.io/v1beta1
    kind: SecretStore
    metadata:
      name: aws-secret-store
    spec:
      provider:
        aws:
          service: SecretsManager
          region: ap-southeast-1
          auth:
            jwt:
              serviceAccountRef:
                name: eso-irsa-sa # Sử dụng IRSA để authenticate
    ```
2.  **ExternalSecret (Định nghĩa secret cần kéo về và K8s Secret đầu ra):**
    ```yaml
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: db-credentials-sync
    spec:
      refreshInterval: "1h" # Tần suất tự động xoay vòng secret
      secretStoreRef:
        name: aws-secret-store # Trỏ tới kết nối ở trên
        kind: SecretStore
      target:
        name: k8s-db-secret # Tên K8s Secret sẽ được sinh ra
      data:
        - secretKey: DB_PASSWORD # Key trong K8s Secret
          remoteRef:
            key: prod/db/creds   # Tên Secret trên AWS Secrets Manager
            property: password   # Key con nằm trong AWS Secret
    ```

---

### 2. Supply Chain Security với Trivy (Quét lỗ hổng)
*   **Mục tiêu:** Phát hiện các lỗ hổng bảo mật (CVE) trong hệ điều hành hoặc thư viện ứng dụng nằm bên trong Container Image trước khi triển khai lên Cluster.
*   **Tích hợp CI Pipeline (Fail-on-error):**
    *   Sau bước build ảnh container, chạy lệnh quét `trivy image <tên_ảnh>`.
    *   Cấu hình `--severity HIGH,CRITICAL --exit-code 1`. Nếu phát hiện lỗ hổng nghiêm trọng, pipeline sẽ lập tức **Thất bại (Fail)** và chặn không cho đẩy ảnh lên Registry.

---
### 3. Image Signing with Cosign (Ký ảnh Container)
*   **Mục tiêu:** Đảm bảo ảnh container chạy trên Cluster là ảnh "sạch" từ nguồn tin cậy của công ty, chống lại việc hacker tấn công vào Registry để tráo ảnh độc hại.
*   **Cơ chế ký ảnh:**
    1.  **Key-based (Dùng cặp khóa):** Dùng private key để ký trong CI pipeline, phân phối public key cho Kubernetes kiểm tra khi deploy.
    2.  **Keyless (Không dùng khóa - Khuyên dùng):** Sử dụng danh tính OIDC ngắn hạn từ pipeline để ký mà không cần quản lý private key (tránh rủi ro lộ khóa).
*   **Admission Verify:** Một chốt chặn (như Kyverno hoặc Gatekeeper) trên K8s sẽ chặn đứng và từ chối deploy bất kỳ Pod nào sử dụng ảnh container chưa được ký bởi Cosign.

---

## 📌 PHẦN C: Platform Integration, Runbook & Cost Guard

### 1. Platform Integration (Tích hợp nền tảng toàn stack)
*   **Mục tiêu:** Liên kết tất cả các công nghệ đã học từ Tuần 8 đến Tuần 10 thành một hệ thống đồng nhất tự động.
*   **Thành phần tích hợp:**
    *   **W8 (Hạ tầng & Giám sát):** GitOps (ArgoCD), Observability (Prometheus, Grafana), Service Mesh (Linkerd/Istio).
    *   **W9 (Vận hành & Canary):** Argo Rollouts để deploy ứng dụng với cơ chế Canary/Blue-green.
    *   **W10 (Bảo mật):** Phân quyền (RBAC), Secrets Management (ESO), Policy Enforcement (Gatekeeper).
*   **Yêu cầu:** Triển khai hạ tầng hoàn chỉnh (Platform Bootstrap) lên một "fresh cluster" (cluster trống hoàn toàn mới) hoàn toàn tự động thông qua GitOps trong thời gian **dưới 2 giờ**.

---

### 2. Resource Management (Quản lý tài nguyên Cluster)
Để ngăn chặn tình trạng một ứng dụng bị lỗi (ví dụ: memory leak) hoặc bị tấn công làm cạn kiệt tài nguyên của toàn bộ Node và ảnh hưởng ứng dụng khác:

#### ⚖️ Phân biệt ResourceQuota vs LimitRange

| Đặc điểm | ResourceQuota (Giới hạn Namespace) | LimitRange (Giới hạn Container) |
| :--- | :--- | :--- |
| **Phạm vi** | Giới hạn **tổng** tài nguyên của Namespace. | Giới hạn tài nguyên của **từng Container**. |
| **Chức năng** | Đặt trần tổng CPU, RAM, số lượng Pod, Service... | Đặt giá trị mặc định (Default Request/Limit) và Min/Max cho container. |
| **Tác dụng** | Ngăn chặn một Namespace chiếm dụng quá mức tài nguyên cluster. | Tự động gán cấu hình tài nguyên nếu lập trình viên quên khai báo trong YAML. |

#### ⚙️ Ví dụ cấu hình LimitRange (Tự động gán mặc định CPU/Memory):
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-min-max-demo-lr
spec:
  limits:
  - default: # Tự động gán LIMIT nếu Pod không khai báo
      cpu: "500m"
      memory: "512Mi"
    defaultRequest: # Tự động gán REQUEST nếu Pod không khai báo
      cpu: "200m"
      memory: "256Mi"
    type: Container
```

---

### 3. Chaos Engineering (Kiểm thử độ bền)
*   **Khái niệm:** Chủ động tự tạo sự cố (tiêm lỗi - inject faults) vào hệ thống đang chạy trong môi trường thử nghiệm (Staging) để đo lường và nâng cao khả năng chịu lỗi.
*   **Mục tiêu kiểm tra:**
    *   K8s có tự động phục hồi (auto-healing) phục hồi pod mới khi pod cũ chết?
    *   Hệ thống monitoring (Grafana/Alertmanager) có gửi cảnh báo đúng lúc?
*   **Công cụ phổ biến:** Chaos Mesh, LitmusChaos (ví dụ: mô phỏng mất mạng, đầy ổ đĩa, sập node).

---

### 4. Incident Response (IR) & Runbooks (Ứng phó sự cố)
*   **Runbook:** Tài liệu hướng dẫn chuẩn (SOP) từng bước xử lý lỗi cụ thể khi nhận được cảnh báo (ví dụ: làm gì khi ổ đĩa đầy, làm gì khi DB mất kết nối).
*   **Quy trình ứng phó sự cố 6 bước:**
    1.  **Detect (Phát hiện):** Nhận cảnh báo từ Prometheus/Grafana hoặc phát hiện bất thường từ AWS GuardDuty.
    2.  **Triage (Đánh giá):** Xác định độ nghiêm trọng và phạm vi ảnh hưởng tới người dùng.
    3.  **Contain (Cô lập):** Ngăn chặn sự cố lan rộng. **(Bước cốt lõi khi hệ thống bị tấn công)**.
    4.  **Eradicate (Loại bỏ):** Xóa mã độc, thu hồi/xoay vòng secrets bị lộ, vá lỗ hổng.
    5.  **Recover (Khôi phục):** Deploy lại bản sạch qua GitOps, kiểm tra hệ thống hoạt động ổn định.
    6.  **Post-mortem (Rút kinh nghiệm):** Phân tích nguyên nhân gốc rễ (RCA) để tránh lỗi lặp lại.

#### 🛠️ Kịch bản cô lập nhanh (Containment) khi K8s bị tấn công:
*   **Nếu 1 Pod bị compromise (bị hacker xâm nhập):**
    *   Áp dụng `NetworkPolicy` chặn toàn bộ kết nối mạng (Ingress & Egress) của Pod này.
    *   Gỡ nhãn (Labels) của Pod đó để ngắt kết nối với `Service`, chặn hoàn toàn traffic của người dùng thật đi vào Pod bị hack (nhưng giữ Pod chạy để SRE vào điều tra).
*   **Nếu 1 Node bị compromise:**
    *   Chạy `kubectl cordon <node-name>` để chặn không cho deploy Pod mới lên Node này.
    *   Chạy `kubectl drain <node-name>` để di dời các Pod sạch sang các Node an toàn khác.
    *   Chụp snapshot đĩa cứng EBS của Node đó để giữ nguyên bằng chứng phân tích.

---

### 5. AWS Cost Anomaly Detection (Quản lý chi phí)
*   **Khái niệm:** Công cụ tự động giám sát chi phí AWS dựa trên Machine Learning.
*   **Mục tiêu:** Phát hiện chi tiêu tăng đột biến bất thường (như cấu hình sai dịch vụ làm tốn tiền, hoặc tài khoản bị hack chạy EC2 đào coin).
*   **Thông báo:** Tự động gửi cảnh báo qua Email/Slack thông qua Amazon EventBridge và SNS để can thiệp kịp thời.
