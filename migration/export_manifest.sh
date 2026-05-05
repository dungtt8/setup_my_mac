#!/bin/bash
set -euo pipefail

# Export everything needed to recreate this Mac dev environment on another Mac.
OUT_DIR="${1:-$PWD/migration/manifest-$(date +%Y%m%d-%H%M%S)}"
INCLUDE_PRIVATE_KEYS="${INCLUDE_PRIVATE_KEYS:-false}"
EXPORT_AWS_CONFIG="${EXPORT_AWS_CONFIG:-true}"
EXPORT_GCLOUD_CONFIG="${EXPORT_GCLOUD_CONFIG:-true}"
EXPORT_DOCKER_CONFIG="${EXPORT_DOCKER_CONFIG:-true}"
EXPORT_COPILOT_CONFIG="${EXPORT_COPILOT_CONFIG:-true}"
EXPORT_VSCODE_USER="${EXPORT_VSCODE_USER:-true}"
EXPORT_VSCODE_EXTENSIONS="${EXPORT_VSCODE_EXTENSIONS:-true}"
EXPORT_WORKSPACE_VSCODE="${EXPORT_WORKSPACE_VSCODE:-true}"

mkdir -p "$OUT_DIR"
mkdir -p "$OUT_DIR/files"

copy_dir_if_exists() {
  local src="$1"
  local dst="$2"
  if [[ -d "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    cp -R "$src" "$dst"
    echo "✅ Exported directory: $src"
  fi
}

copy_file_if_exists() {
  local src="$1"
  local dst="$2"
  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "✅ Exported file: $src"
  fi
}

echo "==> Exporting manifest to: $OUT_DIR"

if ! command -v brew >/dev/null 2>&1; then
  echo "❌ Homebrew is not installed on this machine."
  exit 1
fi

# Homebrew packages that were explicitly installed.
brew leaves | sort > "$OUT_DIR/brew-formula-leaves.txt"
brew list --cask | sort > "$OUT_DIR/brew-casks.txt"

# npm global packages (top-level only).
if command -v npm >/dev/null 2>&1; then
  npm list -g --depth=0 --parseable 2>/dev/null \
    | tail -n +2 \
    | xargs -I{} basename {} \
    | grep -v '^npm$' \
    | sort -u > "$OUT_DIR/npm-global-packages.txt" || true
else
  : > "$OUT_DIR/npm-global-packages.txt"
fi

# Python and Node version managers.
if command -v pyenv >/dev/null 2>&1; then
  pyenv versions --bare | sed '/^system$/d' | sort -u > "$OUT_DIR/pyenv-versions.txt" || true
else
  : > "$OUT_DIR/pyenv-versions.txt"
fi

if command -v nvm >/dev/null 2>&1; then
  nvm ls --no-colors 2>/dev/null \
    | sed 's/->//g' \
    | sed 's/\*//g' \
    | awk '{print $1}' \
    | grep -E '^v[0-9]+' \
    | sort -u > "$OUT_DIR/nvm-versions.txt" || true
else
  : > "$OUT_DIR/nvm-versions.txt"
fi

# Git global config and shell profile files.
copy_file_if_exists "$HOME/.gitconfig" "$OUT_DIR/files/.gitconfig"
copy_file_if_exists "$HOME/.zshrc" "$OUT_DIR/files/.zshrc"
copy_file_if_exists "$HOME/.zprofile" "$OUT_DIR/files/.zprofile"

# SSH config + optional key material.
mkdir -p "$OUT_DIR/files/.ssh"
copy_file_if_exists "$HOME/.ssh/config" "$OUT_DIR/files/.ssh/config"
copy_file_if_exists "$HOME/.ssh/known_hosts" "$OUT_DIR/files/.ssh/known_hosts"

if [[ "$INCLUDE_PRIVATE_KEYS" == "true" ]]; then
  echo "⚠️ INCLUDE_PRIVATE_KEYS=true: exporting private keys as requested"
  cp "$HOME/.ssh/id_"* "$OUT_DIR/files/.ssh/" 2>/dev/null || true
else
  cp "$HOME/.ssh/"*.pub "$OUT_DIR/files/.ssh/" 2>/dev/null || true
fi

if [[ "$EXPORT_AWS_CONFIG" == "true" ]]; then
  copy_dir_if_exists "$HOME/.aws" "$OUT_DIR/files/.aws"
fi

if [[ "$EXPORT_GCLOUD_CONFIG" == "true" ]]; then
  copy_dir_if_exists "$HOME/.config/gcloud" "$OUT_DIR/files/.config/gcloud"
fi

if [[ "$EXPORT_DOCKER_CONFIG" == "true" ]]; then
  copy_dir_if_exists "$HOME/.docker" "$OUT_DIR/files/.docker"
fi

if [[ "$EXPORT_COPILOT_CONFIG" == "true" ]]; then
  copy_dir_if_exists "$HOME/.config/github-copilot" "$OUT_DIR/files/.config/github-copilot"
fi

if [[ "$EXPORT_VSCODE_USER" == "true" ]]; then
  copy_file_if_exists "$HOME/Library/Application Support/Code/User/settings.json" "$OUT_DIR/files/vscode-user/settings.json"
  copy_file_if_exists "$HOME/Library/Application Support/Code/User/keybindings.json" "$OUT_DIR/files/vscode-user/keybindings.json"
  copy_file_if_exists "$HOME/Library/Application Support/Code/User/mcp.json" "$OUT_DIR/files/vscode-user/mcp.json"
  copy_dir_if_exists "$HOME/Library/Application Support/Code/User/snippets" "$OUT_DIR/files/vscode-user/snippets"
  copy_dir_if_exists "$HOME/Library/Application Support/Code/User/prompts" "$OUT_DIR/files/vscode-user/prompts"
fi

if [[ "$EXPORT_VSCODE_EXTENSIONS" == "true" ]] && command -v code >/dev/null 2>&1; then
  code --list-extensions | sort > "$OUT_DIR/vscode-extensions.txt" || true
fi

if [[ "$EXPORT_WORKSPACE_VSCODE" == "true" ]]; then
  copy_dir_if_exists "$PWD/.vscode" "$OUT_DIR/files/workspace/.vscode"
fi

# Save quick machine metadata for traceability.
{
  echo "timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "hostname=$(hostname)"
  echo "os=$(sw_vers -productName)"
  echo "os_version=$(sw_vers -productVersion)"
  echo "arch=$(uname -m)"
} > "$OUT_DIR/metadata.txt"

echo "✅ Export complete"
echo "Manifest: $OUT_DIR"
echo "Next: copy this folder to the new Mac and run migration/apply_manifest.sh <manifest_path>"
