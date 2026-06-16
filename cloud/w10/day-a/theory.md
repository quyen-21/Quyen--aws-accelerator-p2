# W10-Day A: K8s RBAC & Admission Policy

Tài liệu tóm tắt lý thuyết cốt lõi của **W10 - Day A** (RBAC, OPA/Gatekeeper và ValidatingAdmissionPolicy).

---

## 1. Kubernetes RBAC (Role-Based Access Control)

### Ý tưởng cốt lõi
Trả lời câu hỏi: **"AI (Subject) được phép làm HÀNH ĐỘNG GÌ (Verb) trên TÀI NGUYÊN NÀO (Resource)?"**

```
  [Subject]  -------- Gán quyền bằng -------->  [Quyền hạn]
 (User, Group,        (RoleBinding hoặc          (Role hoặc
ServiceAccount)      ClusterRoleBinding)        ClusterRole)
```

### Các đối tượng chính trong RBAC

* **Role (Namespace scope):** Định nghĩa danh sách quyền (get, list, create, delete, update...) đối với các tài nguyên **trong một Namespace** cụ thể.
* **ClusterRole (Cluster scope):** Định nghĩa danh sách quyền đối với các tài nguyên trên **toàn bộ Cluster** (hoặc các tài nguyên phi namespace như Node, Namespace, PersistentVolume).
* **RoleBinding (Namespace scope):** Liên kết một `Role` (hoặc `ClusterRole`) với các `Subject` để áp dụng quyền **chỉ trong Namespace đó**.
* **ClusterRoleBinding (Cluster scope):** Liên kết một `ClusterRole` với các `Subject` để áp dụng quyền trên **toàn bộ Cluster**.

> 💡 **Mẹo:** Bạn có thể tạo một `ClusterRole` dùng chung (ví dụ: `view-pods`) và dùng `RoleBinding` để gán nó cho một User trong Namespace `dev`. Người dùng đó sẽ chỉ có quyền đọc Pod tại Namespace `dev` mà thôi. Cách này giúp tối ưu hóa việc tái sử dụng cấu hình YAML.

### ServiceAccount (SA)
* **User/Group:** Đại diện cho con người (nhà phát triển, quản trị viên). K8s không quản lý trực tiếp mà thông qua cơ chế chứng thực bên ngoài (OIDC/IAM).
* **ServiceAccount (SA):** Đại diện cho **ứng dụng/máy** chạy bên trong Cluster (ví dụ: Pod cần gọi API K8s). Mỗi Pod được gán một SA để xác thực với API Server.

### Lệnh kiểm tra quyền nhanh: `kubectl auth can-i`
* Kiểm tra quyền của chính bạn:
  ```bash
  kubectl auth can-i create deployments
  ```
* Kiểm tra quyền thay thế (impersonate) một ServiceAccount:
  ```bash
  kubectl auth can-i delete pods --as=system:serviceaccount:default:my-service-account
  ```

---

## 2. Admission Policy & OPA/Gatekeeper

### Admission Controller là gì?
Là các chốt chặn trung gian kiểm tra API request gửi tới API Server trước khi dữ liệu được lưu vào etcd:

```
[API Request] ➔ [Authentication] ➔ [Authorization (RBAC)] ➔ [Admission Control] ➔ [etcd]
```

Gồm 2 giai đoạn:
1. **Mutating Webhook:** Tự động **chỉnh sửa hoặc thêm** thông tin vào file YAML gửi lên (Ví dụ: tự động tiêm Sidecar container).
2. **Validating Webhook:** Tiến hành **kiểm tra hợp lệ**. Nếu vi phạm chính sách, request sẽ bị **chặn (Deny)** và trả lỗi về.

### OPA Gatekeeper
* Sử dụng ngôn ngữ **Rego** để khai báo các chính sách bảo mật.
* Gồm 2 thành phần chính:
  * **ConstraintTemplate:** Chứa logic kiểm tra viết bằng mã Rego và khai báo các tham số đầu vào.
  * **Constraint:** Khai báo áp dụng mẫu logic trên cho đối tượng nào (ví dụ: Deployments trong namespace `production`) và điền các tham số cụ thể.

### Chế độ hoạt động (Enforcement Action)
* **enforce (Mặc định):** Chặn đứng request vi phạm ngay lập tức.
* **audit:** Cho phép tài nguyên vi phạm được tạo nhưng ghi nhận lỗi cảnh báo vào status của Constraint phục vụ giám sát và rà quét.

---

## 3. ValidatingAdmissionPolicy (K8s Native)

* Tích hợp sẵn trực tiếp từ phiên bản Kubernetes 1.30 trở đi.
* **Không cần webhook bên thứ ba:** Logic chạy trực tiếp bên trong tiến trình K8s API Server giúp tăng hiệu năng đáng kể và tránh lỗi kết nối mạng.
* **Dễ sử dụng:** Sử dụng cú pháp **CEL (Common Expression Language)** của Google, viết cực kỳ trực quan và ngắn gọn ngay trong file YAML của chính sách mà không cần học Rego.

### So sánh cú pháp kiểm tra replicas Deployment:

* **Gatekeeper (Rego):**
  ```rego
  violation[{"msg": msg}] {
    spec := input.review.object.spec
    spec.replicas > 5
    msg := sprintf("Replicas %v exceeds max of 5", [spec.replicas])
  }
  ```

* **ValidatingAdmissionPolicy (CEL):**
  ```yaml
  validations:
    - expression: "object.spec.replicas <= 5"
      message: "Replicas exceeds maximum limit of 5"
  ```
