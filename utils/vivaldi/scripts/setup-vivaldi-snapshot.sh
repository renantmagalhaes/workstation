#!/usr/bin/env bash
set -euo pipefail

VERSION="8.3.4185.3"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${HOME}/.local/opt/vivaldi-snapshot-8.3"
BIN_DIR="${HOME}/.local/bin"

# 1. Detect architecture
ARCH="$(uname -m)"
if [ "$ARCH" = "x86_64" ]; then
  TAR_NAME="vivaldi-snapshot-${VERSION}-x64.tar"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
  TAR_NAME="vivaldi-snapshot-${VERSION}-arm64.tar"
else
  echo "[-] Unsupported architecture: $ARCH"
  exit 1
fi

TAR_URL="https://downloads.vivaldi.com/snapshot/${TAR_NAME}"

echo "=========================================================="
echo "  Vivaldi Snapshot ${VERSION} Standalone Installer/Runner"
echo "=========================================================="
echo "[+] Detected architecture: ${ARCH}"
echo "[+] Using download URL: ${TAR_URL}"
echo "[+] Target directory: ${TARGET_DIR}"
echo ""

mkdir -p "${TARGET_DIR}" "${BIN_DIR}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "[+] Downloading ${TAR_NAME}..."
curl -fL --progress-bar "${TAR_URL}" -o "${TMP_DIR}/${TAR_NAME}"

echo "[+] Extracting archive..."
tar -xf "${TMP_DIR}/${TAR_NAME}" -C "${TARGET_DIR}" --strip-components=1

# Create dedicated launcher script with pre-loaded extension
LAUNCHER="${BIN_DIR}/vivaldi-snapshot-test"
cat > "${LAUNCHER}" <<EOF
#!/usr/bin/env bash
# Standalone Vivaldi Snapshot 8.3 Runner
# Pre-loads Smart Tab Manager unpacked extension in an isolated test profile
exec "${TARGET_DIR}/vivaldi-snapshot" \\
  --user-data-dir="\$HOME/.config/vivaldi-snapshot-test" \\
  --load-extension="${PROJECT_DIR}" \\
  "\$@"
EOF

chmod +x "${LAUNCHER}"
chmod +x "${TARGET_DIR}/vivaldi-snapshot"
chmod +x "${TARGET_DIR}/testrun"

echo ""
echo "=========================================================="
echo "  Setup Complete!"
echo "=========================================================="
echo "You can now launch Vivaldi Snapshot 8.3 with your extension loaded using:"
echo ""
echo "  vivaldi-snapshot-test"
echo ""
echo "Or run directly:"
echo "  ${LAUNCHER}"
echo ""
echo "Notes:"
echo "- This runs completely isolated using ~/.config/vivaldi-snapshot-test."
echo "- Your regular Vivaldi Stable profile is completely untouched."
echo "- Smart Tab Manager is pre-loaded via --load-extension."
echo "=========================================================="
