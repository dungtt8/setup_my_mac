#!/bin/bash
set -e

echo "🔐 TẠO & CẤU HÌNH SSH KEY CHO GITLAB..."

SSH_KEY="$HOME/.ssh/id_rsa"
EMAIL=$(git config user.email || echo "your-email@example.com")

# Bước 1: Tạo SSH key nếu chưa có
if [ -f "${SSH_KEY}" ]; then
  echo "✅ SSH key đã tồn tại: $SSH_KEY"
else
  echo "📦 Tạo SSH key mới..."
  ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f "$SSH_KEY" -N ""
fi

# Bước 2: Bật SSH agent và thêm key
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY"

# Bước 3: Tạo ~/.ssh/config nếu chưa có
CONFIG="$HOME/.ssh/config"
if ! grep -q "gitlab.devsep.com" "$CONFIG" 2>/dev/null; then
  echo "📄 Cấu hình ssh config cho gitlab.devsep.com..."
  {
    echo ""
    echo "Host gitlab.devsep.com"
    echo "  HostName gitlab.devsep.com"
    echo "  User git"
    echo "  IdentityFile $SSH_KEY"
    echo "  IdentitiesOnly yes"
  } >> "$CONFIG"
else
  echo "✅ ~/.ssh/config đã có cấu hình cho gitlab.devsep.com"
fi

# Bước 4: Hiển thị public key để copy vào GitLab
echo ""
echo "📋 COPY SSH PUBLIC KEY DƯỚI ĐÂY VÀ THÊM VÀO GITLAB:"
echo "👉 https://gitlab.devsep.com/-/user_settings/ssh_keys"
echo "---------------------------------------------"
cat "${SSH_KEY}.pub"
echo "---------------------------------------------"
echo "✅ XONG. Sau khi thêm key, kiểm tra với:"
echo "ssh -T git@gitlab.devsep.com"
