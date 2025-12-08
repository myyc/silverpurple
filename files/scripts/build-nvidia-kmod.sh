#!/usr/bin/env bash
set -euo pipefail

# Build nvidia kernel module during container build
# This works around the akmod-nvidia scriptlet failing when run as root

KERNEL_VERSION=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel)

echo "Building nvidia kmod for kernel ${KERNEL_VERSION}"

# Install build dependencies - exclude akmod-nvidia to prevent scriptlet failure
dnf install -y \
    kernel-devel-${KERNEL_VERSION} \
    akmods \
    rpm-build

# Download nvidia packages and install with --noscripts
# nvidia-kmod-common is a subpackage of xorg-x11-drv-nvidia
dnf download xorg-x11-drv-nvidia xorg-x11-drv-nvidia-kmodsrc akmod-nvidia
rpm -ivh --noscripts --nodeps xorg-x11-drv-nvidia-*.rpm akmod-nvidia-*.rpm
rm -f *.rpm

# Create a non-root user for building with writable directories
useradd -m builder || true
BUILD_DIR=/home/builder/rpmbuild
mkdir -p ${BUILD_DIR}/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
chown -R builder:builder /home/builder

# Make /var/tmp and /tmp writable for the build process
chmod 1777 /var/tmp /tmp

# Build the kmod as non-root user (use home dir for rpmbuild)
su builder -c "akmodsbuild --target $(uname -m) --kernels ${KERNEL_VERSION} /usr/src/akmods/nvidia-kmod.latest"

# Find and install the built kmod
KMOD_RPM=$(find /home/builder -name "kmod-nvidia-*.rpm" 2>/dev/null | head -1)
if [[ -z "${KMOD_RPM}" ]]; then
    echo "ERROR: Failed to find built kmod RPM"
    exit 1
fi

echo "Installing ${KMOD_RPM}"
rpm -ivh "${KMOD_RPM}"

# Cleanup build-only dependencies
userdel -r builder || true
rm -rf /var/tmp/* /tmp/akmodsbuild.* 2>/dev/null || true
rpm -e --nodeps xorg-x11-drv-nvidia-kmodsrc akmod-nvidia
dnf remove -y kernel-devel-${KERNEL_VERSION} rpm-build akmods
dnf autoremove -y
dnf clean all

echo "nvidia kmod build complete"
