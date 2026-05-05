# Chạy nhanh bộ cài chuẩn
```bash
chmod +x install_apps/*.sh
./install_apps/setup_all.sh
```

# Migrate toàn bộ môi trường sang Mac mới

## 1) Trên máy cũ (export)
```bash
chmod +x migration/*.sh
./migration/export_manifest.sh
```

Manifest sẽ nằm tại: `migration/manifest-YYYYMMDD-HHMMSS`

Nếu muốn xuất luôn private SSH keys (cân nhắc bảo mật):
```bash
INCLUDE_PRIVATE_KEYS=true ./migration/export_manifest.sh
```

Tuỳ chọn bật/tắt nhóm cấu hình khi export:
```bash
EXPORT_AWS_CONFIG=true \
EXPORT_GCLOUD_CONFIG=true \
EXPORT_DOCKER_CONFIG=true \
EXPORT_COPILOT_CONFIG=true \
EXPORT_VSCODE_USER=true \
EXPORT_VSCODE_EXTENSIONS=true \
EXPORT_WORKSPACE_VSCODE=true \
./migration/export_manifest.sh
```

## 2) Chép manifest sang máy mới
Copy thư mục manifest vừa tạo sang máy mới (AirDrop, iCloud, USB, rsync...).

## 3) Trên máy mới (apply)
```bash
chmod +x migration/*.sh
./migration/apply_manifest.sh /path/to/manifest-YYYYMMDD-HHMMSS
source ~/.zshrc
```

Tuỳ chọn bật/tắt nhóm cấu hình khi apply:
```bash
APPLY_AWS_CONFIG=true \
APPLY_GCLOUD_CONFIG=true \
APPLY_DOCKER_CONFIG=true \
APPLY_COPILOT_CONFIG=true \
APPLY_VSCODE_USER=true \
APPLY_VSCODE_EXTENSIONS=true \
APPLY_WORKSPACE_VSCODE=false \
./migration/apply_manifest.sh /path/to/manifest-YYYYMMDD-HHMMSS
```

Nếu muốn restore `.vscode` cho một project cụ thể:
```bash
WORKSPACE_DIR=/path/to/your-project \
APPLY_WORKSPACE_VSCODE=true \
./migration/apply_manifest.sh /path/to/manifest-YYYYMMDD-HHMMSS
```
