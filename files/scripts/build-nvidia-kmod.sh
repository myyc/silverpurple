#!/usr/bin/env bash
set -euo pipefail

# Build nvidia kernel module during container build
# This works around the akmod-nvidia scriptlet failing when run as root

KERNEL_VERSION=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel)

echo "Building nvidia kmod for kernel ${KERNEL_VERSION}"

# Install build dependencies using dnf (not rpm-ostree) to avoid scriptlet issues
# We download akmod-nvidia separately and install with --noscripts
dnf install -y \
    kernel-devel-${KERNEL_VERSION} \
    akmods \
    rpm-build

# Download akmod-nvidia without installing
dnf download akmod-nvidia
rpm -ivh --noscripts akmod-nvidia-*.rpm
rm -f akmod-nvidia-*.rpm

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
rpm -ivh "${KMOD_RPM}"

# Cleanup
userdel -r builder || true
dnf remove -y kernel-devel-${KERNEL_VERSION} rpm-build

echo "nvidia kmod build complete"
