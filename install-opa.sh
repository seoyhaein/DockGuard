#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# install-opa.sh
# 자동으로 OPA CLI를 다운로드하여 /usr/local/bin/opa 에 설치하는 스크립트
# ==========================================

# 원하는 OPA 버전을 환경변수로 지정할 수 있습니다 (예: export OPA_VERSION=v1.4.2)
OPA_VERSION=${OPA_VERSION:-v1.4.2}

# 시스템(OS) 및 아키텍처 감지
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Linux만 지원합니다.
if [ "$OS" != "linux" ]; then
  echo "ERROR: Unsupported OS: $OS. This script supports only Linux."
  exit 1
fi

# 아키텍처에 따라 태그 결정
case "$ARCH" in
  x86_64) ARCH_TAG="amd64" ;;
  aarch64|arm64) ARCH_TAG="arm64" ;;
  *) 
    echo "ERROR: Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# 다운로드 URL 구성
DOWNLOAD_URL="https://openpolicyagent.org/downloads/${OPA_VERSION}/opa_${OS}_${ARCH_TAG}_static"

# 임시 디렉터리 생성
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
cd "$TMPDIR"

# 다운로드
echo "Downloading OPA ${OPA_VERSION} for ${OS}/${ARCH_TAG}..."
curl -sSL "$DOWNLOAD_URL" -o opa

# 실행 권한 부여
chmod +x opa

# /usr/local/bin에 설치
echo "Installing to /usr/local/bin/opa (requires sudo)..."
sudo mv opa /usr/local/bin/opa

# 확인
echo "Installed OPA version: $(opa version)"
