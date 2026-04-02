#!/bin/bash
set -e

# Detect chip architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

# Install Homebrew if missing
if ! command -v brew &> /dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\"" >> ~/.zprofile
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"
else
  echo "✅ Homebrew already installed."
fi

# Export arch & prefix for subscripts
export ARCH
export BREW_PREFIX

DIR="$(cd "$(dirname "$0")" && pwd)"

source "$DIR/setup_utils.sh"
source "$DIR/setup_docker_mysql.sh"
source "$DIR/setup_ohmyzsh.sh"
source "$DIR/setup_languages.sh"
source "$DIR/setup_gui_apps.sh"

echo "✅ TOÀN BỘ CÀI ĐẶT ĐÃ HOÀN TẤT!"
