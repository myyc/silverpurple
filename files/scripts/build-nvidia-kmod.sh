#!/usr/bin/env bash
set -euo pipefail

# Build nvidia kernel module during container build
# This works around the akmod-nvidia scriptlet failing when run as root

KERNEL_VERSION=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel)

echo "Building nvidia kmod for kernel ${KERNEL_VERSION}"

# Install build dependencies
rpm-ostree install --idempotent \
    akmod-nvidia \
    kernel-devel-${KERNEL_VERSION} \
    akmods

# Create a non-root user for building
useradd -m builder || true

# Build the kmod as non-root user
su builder -c "akmodsbuild --target $(uname -m) --kernels ${KERNEL_VERSION} /usr/src/akmods/nvidia-kmod.latest"

# Find and install the built kmod
KMOD_RPM=$(find /home/builder -name "kmod-nvidia-*.rpm" | head -1)
if [[ -z "${KMOD_RPM}" ]]; then
    echo "ERROR: Failed to find built kmod RPM"
    exit 1
fi

echo "Installing ${KMOD_RPM}"
rpm-ostree install "${KMOD_RPM}"

# Cleanup build dependencies (keep nvidia driver packages)
rpm-ostree uninstall kernel-devel-${KERNEL_VERSION}
userdel -r builder || true

echo "nvidia kmod build complete"
