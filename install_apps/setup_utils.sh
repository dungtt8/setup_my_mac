#!/bin/bash
echo "🔧 CÀI TIỆN ÍCH CLI & ỨNG DỤNG PHỔ BIẾN..."

# Hàm cài đặt nếu chưa có
install_if_missing() {
  local name="$1"
  local type="$2"  # "formula" hoặc "cask"

  if brew list --"$type" "$name" &>/dev/null; then
    echo "✅ $name đã được cài ($type)"
  else
    echo "📦 Đang cài $name..."
    brew install --"$type" "$name"
  fi
}

# Danh sách cask apps (GUI)
cask_apps=(
  iterm2
  postman
  dbeaver-community
  tunnelblick
)

# Danh sách CLI utilities (formula)
cli_tools=(
  awscli
  aws-vault
  ansible
  tfenv
  terraform
  trivy
  snyk-cli
  jq
  httpie
  wget
  lazygit
  lazydocker
  gh
  glab
  ankitpokhrel/jira-cli/jira-cli
  gitleaks
  act
  tree
  tesseract
  uv
  yarn
  digdag
  sbt
  git
  go
)

# Cài từng cask app
for app in "${cask_apps[@]}"; do
  install_if_missing "$app" cask
done

# Cài từng CLI tool
for tool in "${cli_tools[@]}"; do
  install_if_missing "$tool" formula
done

# AWS Session Manager Plugin
install_session_manager_plugin() {
  if command -v session-manager-plugin &> /dev/null || [ -f "/usr/local/sessionmanagerplugin/bin/session-manager-plugin" ]; then
    echo "✅ AWS Session Manager Plugin đã được cài"
  else
    echo "📦 Đang cài AWS Session Manager Plugin..."
    
    # Tạo thư mục tạm để tải file
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Tải và cài đặt plugin
    echo "⬇️ Đang tải Session Manager Plugin..."
    curl -L -f "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/session-manager-plugin.pkg" -o "session-manager-plugin.pkg"
    
    if [ -f "session-manager-plugin.pkg" ] && [ -s "session-manager-plugin.pkg" ]; then
      echo "🔧 Cài đặt Session Manager Plugin (yêu cầu sudo)..."
      if sudo installer -pkg session-manager-plugin.pkg -target /; then
        # Plugin thường được cài vào /usr/local/sessionmanagerplugin/bin/
        # Thêm vào PATH nếu cần
        if [ -f "/usr/local/sessionmanagerplugin/bin/session-manager-plugin" ]; then
          if ! grep -q "/usr/local/sessionmanagerplugin/bin" ~/.zshrc; then
            echo 'export PATH="/usr/local/sessionmanagerplugin/bin:$PATH"' >> ~/.zshrc
            echo "✅ Đã thêm Session Manager Plugin vào PATH trong ~/.zshrc"
          fi
          export PATH="/usr/local/sessionmanagerplugin/bin:$PATH"
          echo "✅ AWS Session Manager Plugin đã được cài thành công"
        else
          echo "✅ Plugin đã cài nhưng không tìm thấy binary tại vị trí mong đợi"
        fi
      else
        echo "❌ Cài đặt AWS Session Manager Plugin thất bại"
      fi
    else
      echo "❌ Không thể tải Session Manager Plugin"
    fi
    
    # Dọn dẹp file tạm
    cd - > /dev/null
    rm -rf "$temp_dir"
  fi
}

# Cài AWS Session Manager Plugin
install_session_manager_plugin

