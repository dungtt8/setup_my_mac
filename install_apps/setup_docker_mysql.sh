#!/bin/bash
echo "🐳 CÀI ĐẶT DOCKER & CHẠY MYSQL..."

# Detect chip
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

# Cài docker nếu chưa có
if ! command -v docker &> /dev/null; then
  echo "📦 Cài docker CLI..."
  brew install docker
else
  echo "✅ Docker đã được cài."
fi

# Cài colima nếu chưa có
if ! command -v colima &> /dev/null; then
  echo "📦 Cài colima..."
  brew install colima
else
  echo "✅ Colima đã được cài."
fi

# Cài docker-compose nếu chưa có
if ! command -v docker-compose &> /dev/null; then
  echo "📦 Cài docker-compose..."
  brew install docker-compose
else
  echo "✅ Docker Compose đã được cài."
fi

# Khởi động colima nếu chưa chạy
if ! colima status | grep -q "Running"; then
  echo "⚡ Khởi động colima..."
  colima start --cpu 2 --memory 4 --disk 20
else
  echo "✅ Colima đang chạy."
fi

# Cài mysql CLI nếu chưa có
if ! command -v mysql &> /dev/null; then
  echo "📦 Cài MySQL CLI..."
  brew install mysql
else
  echo "✅ MySQL CLI đã được cài."
fi

# Kéo image nếu chưa có
for version in 5.7 8.0; do
  if ! docker image ls | grep -q "mysql\s*$version"; then
    echo "⬇️ Kéo image mysql:$version"
    docker pull mysql:$version
  else
    echo "✅ Image mysql:$version đã có."
  fi
done

# Hàm chạy container nếu chưa có
run_mysql_container() {
  NAME=$1
  VERSION=$2
  PORT=$3
  if ! docker ps -a --format '{{.Names}}' | grep -q "^$NAME$"; then
    echo "🚀 Tạo container $NAME..."
    docker run -d \
      --name "$NAME" \
      -e MYSQL_ROOT_PASSWORD=123qweasdzxc@@ \
      -p "$PORT":3306 \
      -v "${NAME}_data":/var/lib/mysql \
      mysql:"$VERSION"
  else
    echo "✅ Container $NAME đã tồn tại."
  fi
}

# Tạo 2 container
run_mysql_container mysql57 5.7 33061
run_mysql_container mysql80 8.0 3306
