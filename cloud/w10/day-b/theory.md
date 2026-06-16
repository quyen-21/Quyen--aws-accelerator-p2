# W10-Day B: Secrets Rotation & Supply Chain Security

Tài liệu tóm tắt lý thuyết cốt lời của **W10 - Day B** (AWS Secrets Manager, External Secrets Operator - ESO, Trivy scan, Cosign signing và Admission Verify).

---

## 1. Secrets Rotation với External Secrets Operator (ESO)

### Vấn đề thực tế
* Lưu thông tin nhạy cảm (mật khẩu database, API key) trực tiếp trong file YAML của Git repo (GitOps) là cực kỳ nguy hiểm.
* Kubernetes Secret thông thường chỉ được mã hóa Base64 đơn giản (không an toàn) và rất khó quản lý việc xoay vòng tự động (rotation) khi mật khẩu thay đổi.

### Giải pháp: Sử dụng ESO + AWS Secrets Manager
External Secrets Operator (ESO) là một Operator chạy trong Kubernetes giúp đồng bộ tự động dữ liệu nhạy cảm từ các dịch vụ bên ngoài (như AWS Secrets Manager, HashiCorp Vault) vào thành Kubernetes Secret native.

```
[AWS Secrets Manager] ➔ (Đồng bộ qua ESO) ➔ [K8s Secret] ➔ [Pod đọc ứng dụng]
```

### Các thành phần chính của ESO (CRDs)
1. **SecretStore / ClusterSecretStore:**
   * Cấu hình kết nối và phương thức xác thực tới AWS Secrets Manager.
   * Nên sử dụng **IRSA (IAM Roles for Service Accounts)** để gán IAM Role có quyền đọc secret cho ServiceAccount của ESO, tránh việc lưu cứng Access Key/Secret Key của AWS.
   * `SecretStore` có phạm vi trong 1 Namespace; `ClusterSecretStore` có phạm vi trên toàn Cluster.
2. **ExternalSecret:**
   * Định nghĩa việc kéo secret cụ thể nào trên AWS về.
   * Khai báo tên K8s Secret đầu ra và ánh xạ các key-value.
   * Cấu hình tham số `refreshInterval` (ví dụ: `60s` hoặc `1m`). Cứ sau mỗi khoảng thời gian này, ESO sẽ tự động kiểm tra xem AWS Secrets Manager có thay đổi gì không để cập nhật xuống K8s Secret.

### Cơ chế xoay vòng không cần restart Pod (No-restart)
Khi K8s Secret thay đổi, làm thế nào để ứng dụng cập nhật cấu hình mới mà không phải khởi động lại Pod?
* **Cách 1: Mount Secret dưới dạng Volume.** Kubernetes sẽ tự động cập nhật nội dung file secret được mount trong container sau khoảng 1–2 phút. Ứng dụng cần có logic tự đọc lại file cấu hình khi file thay đổi.
* **Cách 2: Sử dụng công cụ bổ trợ (ví dụ: Reloader).** Reloader giám sát ConfigMap/Secret. Khi phát hiện thay đổi, nó sẽ tự động kích hoạt một tiến trình Rolling Upgrade (khởi động lại Pod một cách an toàn) cho ứng dụng.

---

## 2. Supply Chain Security với Trivy

### Tại sao cần quét ảnh container?
Ảnh container (Container Image) được build từ các base image và thư viện bên thứ ba (như npm, pip, apt). Các thư viện này có thể chứa lỗ hổng bảo mật (CVE) nguy hiểm bị hacker khai thác.

### Trivy là gì?
Trivy là một công cụ quét bảo mật mã nguồn mở, hoạt động cực kỳ nhanh và chính xác. Nó có thể quét:
* Lỗ hổng hệ điều hành và thư viện ngôn ngữ lập trình (CVE).
* Các lỗi cấu hình sai (IaC misconfiguration).
* Các thông tin nhạy cảm bị lộ (secret scanning).

### Cấu hình trong CI Pipeline (Fail-on-error)
Tích hợp Trivy vào luồng CI (như GitHub Actions) sau bước build ảnh container. Cấu hình quy tắc:
* Quét ảnh container vừa build.
* Sử dụng cờ cảnh báo mức độ nguy hiểm: `--severity HIGH,CRITICAL`.
* Đặt mã thoát khi phát hiện lỗi: `--exit-code 1`.
* **Kết quả:** Nếu ảnh có lỗi bảo mật nghiêm trọng, pipeline CI sẽ lập tức **thất bại (Fail)** và chặn không cho phép đẩy (push) ảnh lỗi này lên ECR/Docker Hub.

---

## 3. Image Signing với Cosign (Sigstore)

### Tại sao cần ký ảnh container?
Chỉ quét ảnh trong CI là chưa đủ. Hacker vẫn có thể tấn công vào Container Registry để tráo đổi ảnh container sạch bằng một ảnh độc hại nhưng vẫn giữ nguyên nhãn (tag) giống hệt.

```
[CI Build & Scan] ➔ [Ký ảnh bằng Cosign] ➔ [Đẩy Registry] ➔ [Admission Controller xác thực chữ ký] ➔ [Deploy Pod]
```

### Cosign là gì?
Cosign là công cụ thuộc dự án Sigstore, chuyên dùng để ký và xác thực các artifact (đặc biệt là container image) trên Registry.

### Hai phương pháp ký ảnh bằng Cosign:
1. **Key-based (Dùng cặp khóa):**
   * Tạo cặp khóa public/private (`cosign generate-key-pair`).
   * Dùng private key để ký trong CI pipeline. Public key được cấu hình trên Kubernetes Cluster.
   * Nhược điểm: Phải quản lý và bảo mật private key cẩn thận.
2. **Keyless (Không dùng khóa - Khuyên dùng):**
   * Xác thực danh tính của pipeline build (ví dụ: GitHub Actions run) thông qua giao thức OIDC (OpenID Connect).
   * Hệ thống Sigstore (Fulcio) cấp chứng chỉ số ngắn hạn (chỉ tồn tại trong vài phút) để ký ảnh.
   * Ghi nhận giao dịch ký vào sổ cái công khai (Rekor) để đối chiếu.
   * Lợi ích: Không cần quản lý hay lo sợ lộ private key.

### Xác thực chữ ký ở mức Admission Control
* Cài đặt một Admission Controller (như Kyverno hoặc Gatekeeper) trên Kubernetes Cluster.
* Cấu hình chính sách: Khi có yêu cầu tạo Pod, Admission Controller sẽ kiểm tra xem ảnh container đó đã được ký bởi khóa tin cậy hoặc danh tính OIDC hợp lệ của bạn chưa.
* Nếu chưa được ký ➔ **Từ chối deploy**.

---

## 4. Exception Policy (Chính sách ngoại lệ)

* **Thực tế:** Đôi khi phát hiện một lỗ hổng CVE mức độ HIGH trên ảnh, nhưng thư viện đó bắt buộc phải sử dụng và chưa có bản vá từ nhà cung cấp. Nếu cứ để Trivy chặn thì dự án không thể deploy được.
* **Giải pháp:** Thiết lập chính sách ngoại lệ có thời hạn bằng tài liệu **ADR (Architecture Decision Record)**.
* **Cách làm:** Cấu hình Trivy hoặc Admission Webhook bỏ qua mã CVE cụ thể đó trong một khoảng thời gian giới hạn (ví dụ: 15–30 ngày) để đội phát triển tìm phương án thay thế, đảm bảo tính liên tục của hệ thống nhưng vẫn nằm trong tầm kiểm soát an toàn.
