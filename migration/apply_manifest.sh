#!/bin/bash
set -euo pipefail

MANIFEST_DIR="${1:-}"
APPLY_AWS_CONFIG="${APPLY_AWS_CONFIG:-true}"
APPLY_GCLOUD_CONFIG="${APPLY_GCLOUD_CONFIG:-true}"
APPLY_DOCKER_CONFIG="${APPLY_DOCKER_CONFIG:-true}"
APPLY_COPILOT_CONFIG="${APPLY_COPILOT_CONFIG:-true}"
APPLY_VSCODE_USER="${APPLY_VSCODE_USER:-true}"
APPLY_VSCODE_EXTENSIONS="${APPLY_VSCODE_EXTENSIONS:-true}"
APPLY_WORKSPACE_VSCODE="${APPLY_WORKSPACE_VSCODE:-false}"
WORKSPACE_DIR="${WORKSPACE_DIR:-}"

if [[ -z "$MANIFEST_DIR" ]]; then
  echo "Usage: $0 <manifest_dir>"
  exit 1
fi

if [[ ! -d "$MANIFEST_DIR" ]]; then
  echo "❌ Manifest directory does not exist: $MANIFEST_DIR"
  exit 1
fi

if [[ ! -f "$MANIFEST_DIR/brew-formula-leaves.txt" ]]; then
  echo "❌ Missing file: $MANIFEST_DIR/brew-formula-leaves.txt"
  exit 1
fi

# Install Homebrew if needed.
if ! command -v brew >/dev/null 2>&1; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

echo "==> Installing Homebrew formulae..."
while IFS= read -r formula; do
  [[ -z "$formula" ]] && continue
  if brew list --formula "$formula" >/dev/null 2>&1; then
    echo "✅ $formula already installed"
  else
    echo "📦 Installing $formula"
    brew install "$formula"
  fi
done < "$MANIFEST_DIR/brew-formula-leaves.txt"

echo "==> Installing Homebrew casks..."
if [[ -f "$MANIFEST_DIR/brew-casks.txt" ]]; then
  while IFS= read -r cask; do
    [[ -z "$cask" ]] && continue
    if brew list --cask "$cask" >/dev/null 2>&1; then
      echo "✅ $cask already installed"
    else
      echo "📦 Installing $cask"
      brew install --cask "$cask"
    fi
  done < "$MANIFEST_DIR/brew-casks.txt"
fi

# Restore git/zsh files with backup of existing files.
restore_file() {
  local src="$1"
  local dst="$2"
  if [[ -f "$src" ]]; then
    if [[ -f "$dst" ]]; then
      cp "$dst" "$dst.bak.$(date +%Y%m%d-%H%M%S)"
    fi
    cp "$src" "$dst"
    echo "✅ Restored $dst"
  fi
}

restore_dir() {
  local src="$1"
  local dst="$2"
  if [[ -d "$src" ]]; then
    if [[ -d "$dst" ]]; then
      local backup_path="${dst}.bak.$(date +%Y%m%d-%H%M%S)"
      cp -R "$dst" "$backup_path"
    fi
    mkdir -p "$(dirname "$dst")"
    rm -rf "$dst"
    cp -R "$src" "$dst"
    echo "✅ Restored $dst"
  fi
}

restore_file "$MANIFEST_DIR/files/.gitconfig" "$HOME/.gitconfig"
restore_file "$MANIFEST_DIR/files/.zshrc" "$HOME/.zshrc"
restore_file "$MANIFEST_DIR/files/.zprofile" "$HOME/.zprofile"

# Restore SSH folder content.
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [[ -d "$MANIFEST_DIR/files/.ssh" ]]; then
  cp "$MANIFEST_DIR/files/.ssh/"* "$HOME/.ssh/" 2>/dev/null || true
  chmod 600 "$HOME/.ssh/"* 2>/dev/null || true
  chmod 644 "$HOME/.ssh/"*.pub 2>/dev/null || true
  echo "✅ Restored SSH files"
fi

if [[ "$APPLY_AWS_CONFIG" == "true" ]]; then
  restore_dir "$MANIFEST_DIR/files/.aws" "$HOME/.aws"
fi

if [[ "$APPLY_GCLOUD_CONFIG" == "true" ]]; then
  restore_dir "$MANIFEST_DIR/files/.config/gcloud" "$HOME/.config/gcloud"
fi

if [[ "$APPLY_DOCKER_CONFIG" == "true" ]]; then
  restore_dir "$MANIFEST_DIR/files/.docker" "$HOME/.docker"
fi

if [[ "$APPLY_COPILOT_CONFIG" == "true" ]]; then
  restore_dir "$MANIFEST_DIR/files/.config/github-copilot" "$HOME/.config/github-copilot"
fi

if [[ "$APPLY_VSCODE_USER" == "true" ]]; then
  restore_file "$MANIFEST_DIR/files/vscode-user/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
  restore_file "$MANIFEST_DIR/files/vscode-user/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
  restore_file "$MANIFEST_DIR/files/vscode-user/mcp.json" "$HOME/Library/Application Support/Code/User/mcp.json"
  restore_dir "$MANIFEST_DIR/files/vscode-user/snippets" "$HOME/Library/Application Support/Code/User/snippets"
  restore_dir "$MANIFEST_DIR/files/vscode-user/prompts" "$HOME/Library/Application Support/Code/User/prompts"
fi

if [[ "$APPLY_VSCODE_EXTENSIONS" == "true" ]] && [[ -f "$MANIFEST_DIR/vscode-extensions.txt" ]] && command -v code >/dev/null 2>&1; then
  while IFS= read -r ext; do
    [[ -z "$ext" ]] && continue
    echo "📦 code --install-extension $ext"
    code --install-extension "$ext" || true
  done < "$MANIFEST_DIR/vscode-extensions.txt"
fi

if [[ "$APPLY_WORKSPACE_VSCODE" == "true" ]]; then
  if [[ -z "$WORKSPACE_DIR" ]]; then
    echo "⚠️ APPLY_WORKSPACE_VSCODE=true nhưng chưa set WORKSPACE_DIR, bỏ qua restore .vscode"
  else
    restore_dir "$MANIFEST_DIR/files/workspace/.vscode" "$WORKSPACE_DIR/.vscode"
  fi
fi

# Install npm global packages.
if [[ -f "$MANIFEST_DIR/npm-global-packages.txt" ]] && command -v npm >/dev/null 2>&1; then
  while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    echo "📦 npm -g install $pkg"
    npm install -g "$pkg" || true
  done < "$MANIFEST_DIR/npm-global-packages.txt"
fi

# Install pyenv versions if pyenv exists.
if [[ -f "$MANIFEST_DIR/pyenv-versions.txt" ]] && command -v pyenv >/dev/null 2>&1; then
  while IFS= read -r pyver; do
    [[ -z "$pyver" ]] && continue
    if pyenv versions --bare | grep -qx "$pyver"; then
      echo "✅ Python $pyver already installed in pyenv"
    else
      echo "📦 pyenv install $pyver"
      pyenv install "$pyver" || true
    fi
  done < "$MANIFEST_DIR/pyenv-versions.txt"
fi

# Install nvm versions if nvm exists.
if [[ -f "$MANIFEST_DIR/nvm-versions.txt" ]] && command -v nvm >/dev/null 2>&1; then
  while IFS= read -r nodever; do
    [[ -z "$nodever" ]] && continue
    echo "📦 nvm install $nodever"
    nvm install "$nodever" || true
  done < "$MANIFEST_DIR/nvm-versions.txt"
fi

echo "✅ Apply complete"
echo "Run: source ~/.zshrc"
