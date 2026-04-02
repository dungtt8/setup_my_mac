# 🧰 macOS Dev Setup

Bộ script tự động cài đặt môi trường phát triển hiện đại cho macOS, bao gồm:

* Docker, MySQL
* Oh My Zsh + plugins + font đẹp
* Java, Python, Node.js (NestJS, ReactJS)
* Các công cụ CLI phổ biến
* Các ứng dụng GUI cần thiết

---

## 🚀 Cách sử dụng nhanh

```bash
# Clone repo chứa các script
git clone https://your-repo-url.git
cd your-repo

# Cấp quyền và chạy script tổng
chmod +x *.sh
./setup_all.sh
```

---

## 📁 Các script và chức năng

### 🎯 `setup_all.sh` - Script tổng
- Tự động phát hiện chip (Intel/Apple Silicon)
- Cài đặt Homebrew nếu chưa có
- Gọi tất cả các script con theo thứ tự

### 🔧 `setup_utils.sh` - Tiện ích CLI & GUI
**CLI Tools:**
- `awscli` - AWS Command Line Interface
- `aws-vault` - AWS credential vault
- `tfenv` - Terraform version manager
- `terraform` - Infrastructure as code
- `trivy` - Security scanner
- `snyk-cli` - Security testing
- `jq` - JSON processor
- `httpie` - HTTP client
- `wget` - File downloader
- `lazygit` - Git TUI
- `lazydocker` - Docker TUI
- `gh` - GitHub CLI
- `gitleaks` - Secrets scanner
- `act` - Run GitHub Actions locally
- `tree` - Directory tree viewer
- `yarn` - Package manager
- `digdag` - Workflow engine
- `sbt` - Scala build tool
- **AWS Session Manager Plugin** - Kết nối EC2 qua Session Manager

**GUI Applications:**
- `iterm2` - Terminal emulator
- `postman` - API testing tool
- `dbeaver-community` - Database management
- `tunnelblick` - VPN client

### 🐳 `setup_docker_mysql.sh` - Docker & MySQL
**Docker:**
- `docker` - Docker CLI
- `docker-compose` - Docker Compose CLI
- `colima` - Docker container runtime
- Tự động khởi động Colima với 2 CPU, 4GB RAM, 20GB disk

**MySQL:**
- `mysql` - MySQL CLI client
- Docker images: `mysql:5.7`, `mysql:8.0`

### 💻 `setup_ohmyzsh.sh` - Shell Enhancement
- **Oh My Zsh** - Zsh framework
- **Plugins:**
  - `zsh-autosuggestions` - Command suggestions
  - `zsh-syntax-highlighting` - Syntax highlighting
- **Font:** `font-fira-code` - Programming font

### 🧠 `setup_languages.sh` - Programming Languages
**Java:**
- `jenv` - Java version manager
- `openjdk@8` - Java 8
- `openjdk@11` - Java 11
- `openjdk@17` - Java 17 (default)
- `openjdk@21` - Java 21
- `openjdk` - Java latest
- Tự động cấu hình JAVA_HOME

**Python:**
- `pyenv` - Python version manager
- Python 3.11.9 (default)
- Tự động cấu hình PYTHONPATH

**Node.js:**
- `nvm` - Node version manager
- Node.js LTS (latest)
- Tự động cấu hình NVM

### 🖥️ `setup_gui_apps.sh` - GUI Applications
- `google-chrome` - Web browser
- `visual-studio-code` - Code editor
- `slack` - Team communication
- `brave-browser` - Privacy-focused browser
- `intellij-idea` - Java IDE
- `windows-app` - Windows virtualization
- `evkey` - Vietnamese keyboard (Telex/VNI)
- `openkey` - Vietnamese keyboard (open source)
- `snowflake-snowsql` - Snowflake CLI

---

## 🔧 Tuỳ chỉnh

### 🧩 Tắt/bật phần cài đặt cụ thể

Trong `setup_all.sh`, bạn có thể comment dòng không cần:

```bash
# source "$DIR/setup_docker_mysql.sh"  # Bỏ qua nếu không dùng Docker
source "$DIR/setup_languages.sh"       # Cài phần ngôn ngữ lập trình
```

### 🛠 Thêm CLI/GUIs mới

Trong `setup_utils.sh`, thêm vào mảng tương ứng:

```bash
# Thêm CLI tool
cli_tools=(
  # ...existing tools...
  your-new-cli-tool
)

# Thêm GUI app
cask_apps=(
  # ...existing apps...
  your-new-gui-app
)
```

### 🗄️ Thêm Database khác

Trong `setup_docker_mysql.sh`, thêm Docker image:

```bash
# Thêm PostgreSQL
docker pull postgres:15
docker pull postgres:14
```

---

## 📌 Tips

### ✅ Kiểm tra cài đặt
```bash
# Kiểm tra Java versions
jenv versions

# Kiểm tra Python versions  
pyenv versions

# Kiểm tra Node versions
nvm list

# Kiểm tra Docker
docker ps
colima status
docker-compose --version
```

### 🔄 Cập nhật tools
```bash
# Cập nhật Homebrew packages
brew update && brew upgrade

# Cập nhật Node.js
nvm install --lts --reinstall-packages-from=current

# Cập nhật Python
pyenv install 3.12.0 && pyenv global 3.12.0
```

### 🐛 Troubleshooting
- **Homebrew permission**: `sudo chown -R $(whoami) /opt/homebrew`
- **Shell không nhận tool**: Restart terminal hoặc `source ~/.zshrc`
- **Docker không chạy**: `colima restart`
- **Java JAVA_HOME**: Kiểm tra `echo $JAVA_HOME`

### 📋 Thông tin cài đặt
* Script không cài lại nếu đã có tool/app
* Shell được cấu hình `.zshrc` với `jenv`, `pyenv`, `nvm`
* Font và plugins Zsh sẽ tự động được thêm nếu chưa có
* Chip máy sẽ được phát hiện tự động để set đúng path Homebrew (`/opt/homebrew` hoặc `/usr/local`)
* AWS Session Manager Plugin được cài và thêm vào PATH tự động

---

## 💡 Gợi ý mở rộng

### 🔬 Data Science
```bash
# Thêm vào setup_languages.sh
brew install --cask miniconda
conda install pandas numpy matplotlib jupyter
```

### 🗄️ Databases
```bash
# Thêm vào setup_docker_mysql.sh
docker pull postgres:15
docker pull redis:7-alpine
docker pull mongodb/mongodb-community-server:7.0-ubi8
```

### 🐳 Docker Compose Example
```yaml
# Tạo file docker-compose.yml
version: '3'
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: myapp
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  mysql_data:
```

### 🔐 Security & Keys
```bash
# Tạo script setup_security.sh
ssh-keygen -t ed25519 -C "your_email@example.com"
gpg --full-generate-key
git config --global user.signingkey YOUR_KEY_ID
```

### 🌐 Web Development
```bash
# Thêm vào setup_languages.sh
npm install -g @nestjs/cli
npm install -g create-react-app
npm install -g typescript
npm install -g prettier eslint
```

---

## 🛠 Yêu cầu

* macOS >= 11 (Intel hoặc M1/M2/M3)
* Terminal `zsh`
* Kết nối mạng khi cài đặt

---

## 📝 Giấy phép

Tùy chọn: MIT / Apache 2.0 / Internal Use Only

---

## 🤝 Đóng góp

PR, issue, ý kiến, pull request đều được hoan nghênh!
