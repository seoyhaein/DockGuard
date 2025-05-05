#!/usr/bin/env bash
set -euo pipefail

# 1) 최신 버전 태그 가져오기 (vX.Y.Z 형식)
LATEST_VERSION=$(curl -sSL https://api.github.com/repos/open-policy-agent/conftest/releases/latest \
  | grep '"tag_name":' \
  | sed -E 's/.*"([^"]+)".*/\1/' \
  | cut -c 2-)

# 2) 운영체제 및 아키텍처 감지
SYSTEM=$(uname -s)   # e.g. Linux
ARCH=$(uname -m)     # e.g. x86_64

# 3) 다운로드 URL 구성
DOWNLOAD_URL="https://github.com/open-policy-agent/conftest/releases/download/v${LATEST_VERSION}/conftest_${LATEST_VERSION}_${SYSTEM}_${ARCH}.tar.gz"

# 4) 임시 디렉터리에서 다운로드·압축 해제
TMPDIR=$(mktemp -d)
cd "$TMPDIR"
echo "Downloading Conftest ${LATEST_VERSION} for ${SYSTEM}/${ARCH}..."
curl -sSL "$DOWNLOAD_URL" -o conftest.tar.gz

echo "Extracting..."
tar -xzf conftest.tar.gz

# 5) 실행 권한 부여 및 /usr/local/bin에 이동
chmod +x conftest
sudo mv conftest /usr/local/bin/

# 6) 정리 및 확인
cd -
rm -rf "$TMPDIR"

echo "Conftest installed successfully:"
conftest --version
