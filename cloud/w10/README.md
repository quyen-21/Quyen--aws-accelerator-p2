# W10 — Secure & Operate: RBAC + Secrets + Platform Integration

Thư mục chứa nội dung tự học, thực hành lab và tài liệu ôn tập của Tuần 10.

## 📂 Cấu Trúc Thư Mục

* [**day-a/**]: Phân quyền (RBAC) & Admission Policy
  * [theory.md]: 📝 Kiến thức trọng tâm tinh gọn (RBAC, Gatekeeper/OPA, ValidatingAdmissionPolicy).
 
* [**day-b/**]: Secrets Rotation & Supply Chain Security (AWS Secrets Manager, ESO, Trivy, Cosign).
  * [theory.md]: 📝 Kiến thức trọng tâm tinh gọn (ESO, Trivy scan, Cosign signing).
 
* [**day-c/**]: Platform Integration (ResourceQuota, LimitRange, Runbooks, Chaos Testing, Cost Guard).
  * [theory.md]: 📝 Kiến thức trọng tâm tinh gọn (Platform Bootstrap, ResourceQuota, LimitRange, Incident Response, Cost Guard).
  * `platform-bootstrap/`: Bộ manifest/kustomize/helm để dựng nhanh platform.
  * `runbooks/`: Tài liệu ứng phó sự cố & template post-mortem.
* **lab/**: Chứa kết quả xử lý Lab "6-risk cluster cleanup + cluster-level enforcement".
* [**summary.md**]: 📊 Tài liệu tóm tắt kiến thức tổng hợp rút gọn (RBAC, Admission Policy, ESO, Trivy, Cosign) dùng để trình bày báo cáo.
* **reflection.md**: Bài học rút ra và tự đánh giá sau tuần học.

---