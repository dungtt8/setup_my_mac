#!/bin/bash
echo "🧠 CÀI NGÔN NGỮ LẬP TRÌNH..."

# Detect chip
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

append_if_missing() {
  local line="$1"
  grep -qxF "$line" "$ZSHRC" || echo "$line" >> "$ZSHRC"
}

# ===================== JAVA + JENV =====================
brew list jenv &>/dev/null || brew install jenv
brew list openjdk@8 &>/dev/null || brew install openjdk@8
brew list openjdk@11 &>/dev/null || brew install openjdk@11
brew list openjdk@17 &>/dev/null || brew install openjdk@17
brew list openjdk@21 &>/dev/null || brew install openjdk@21
brew list openjdk &>/dev/null || brew install openjdk

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

jenv add "$BREW_PREFIX/opt/openjdk@8" || true
jenv add "$BREW_PREFIX/opt/openjdk@11" || true
jenv add "$BREW_PREFIX/opt/openjdk@17" || true
jenv add "$BREW_PREFIX/opt/openjdk@21" || true
jenv add "$BREW_PREFIX/opt/openjdk" || true

JAVA17=$(jenv versions | grep -E '^\s*17' | sed 's/^[* ]*//' | head -n1)
if [[ -n "$JAVA17" ]]; then
  echo "✅ Đặt jenv global $JAVA17"
  jenv global "$JAVA17"
else
  echo "⚠️ Không tìm thấy Java 17 để đặt làm global"
fi

# Append Java env
append_if_missing 'export PATH="$HOME/.jenv/bin:$PATH"'
append_if_missing 'eval "$(jenv init -)"'
append_if_missing 'export JAVA_HOME="$HOME/.jenv/versions/$(jenv version-name)"'
append_if_missing 'export PATH="$JAVA_HOME/bin:$PATH"'

# ===================== PYTHON + PYENV =====================
brew list pyenv &>/dev/null || brew install pyenv

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

if ! pyenv versions | grep -q "3.11.9"; then
  pyenv install 3.11.9
fi
pyenv global 3.11.9

# Append Python env
append_if_missing 'export PYENV_ROOT="$HOME/.pyenv"'
append_if_missing 'export PATH="$PYENV_ROOT/bin:$PATH"'
append_if_missing 'eval "$(pyenv init --path)"'
append_if_missing '# ⚠️ Điều chỉnh phiên bản nếu bạn dùng Python khác'
append_if_missing 'export PYTHONPATH="$HOME/.pyenv/versions/$(pyenv version-name)/lib/python3.11/site-packages:$PYTHONPATH"'

# ===================== NODE + NVM =====================
brew list nvm &>/dev/null || brew install nvm
mkdir -p "$HOME/.nvm"

if [[ "$ARCH" == "arm64" ]]; then
  NVM_ROOT="/opt/homebrew/opt/nvm"
else
  NVM_ROOT="/usr/local/opt/nvm"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_ROOT/nvm.sh" ] && \. "$NVM_ROOT/nvm.sh"
[ -s "$NVM_ROOT/etc/bash_completion.d/nvm" ] && \. "$NVM_ROOT/etc/bash_completion.d/nvm"

nvm install --lts
nvm use --lts
nvm alias default lts/*

# Append Node env
append_if_missing 'export NVM_DIR="$HOME/.nvm"'
append_if_missing "[ -s \"$NVM_ROOT/nvm.sh\" ] && \. \"$NVM_ROOT/nvm.sh\""
append_if_missing "[ -s \"$NVM_ROOT/etc/bash_completion.d/nvm\" ] && \. \"$NVM_ROOT/etc/bash_completion.d/nvm\""
append_if_missing '[ -n "$(command -v nvm)" ] && nvm use default &>/dev/null'

# ===================== FULLSTACK TOOLS =====================
echo "🧱 CÀI CÔNG CỤ PHÁT TRIỂN FULLSTACK..."
npm install -g @nestjs/cli || echo "⚠️ Không thể cài NestJS CLI"
npm install -g create-react-app || echo "⚠️ Không thể cài Create React App"
brew list yarn &>/dev/null || brew install yarn

# ===================== SCALA + SBT =====================
brew list sbt &>/dev/null || brew install sbt

# ===================== HOÀN TẤT =====================
echo "✅ CÀI NGÔN NGỮ LẬP TRÌNH & FULLSTACK TOOL HOÀN TẤT!"
echo "✅ ~/.zshrc đã được cập nhật."
echo "🔄 Vui lòng khởi động lại terminal hoặc chạy: source ~/.zshrc"
