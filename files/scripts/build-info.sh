#!/usr/bin/env bash
# Sets build timestamp in os-release for version tracking
set -euo pipefail

BUILD_DATE=$(date +%Y%m%d)
BUILD_HASH=$(head -c 4 /proc/sys/kernel/random/boot_id | xxd -p)

VERSION="${BUILD_DATE}.${BUILD_HASH}"

# Update os-release with version info
cat >> /etc/os-release <<EOF
BUILD_ID="${VERSION}"
VARIANT="Silverpurple"
VARIANT_ID=silverpurple
EOF

# Update PRETTY_NAME to include version
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Silverpurple (${VERSION})\"/" /etc/os-release
