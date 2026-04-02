#!/bin/bash
echo "🖥️ CÀI ỨNG DỤNG GIAO DIỆN NGƯỜI DÙNG..."

install_app() {
  local app="$1"
  if brew list --cask "$app" &> /dev/null; then
    echo "✅ $app đã được cài."
  else
    echo "📦 Cài $app..."
    brew install --cask "$app"
  fi
}

# Danh sách app cần cài
apps=(
  google-chrome
  visual-studio-code
  slack
  brave-browser
  windows-app
  evkey
  openkey
  copilot-cli
)

for app in "${apps[@]}"; do
  install_app "$app"
done
