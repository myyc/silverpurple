# Silverpurple

Custom Fedora Silverblue 43 image built with [BlueBuild](https://blue-build.org/).

## Images

| Image | Description |
|-------|-------------|
| `ghcr.io/myyc/silverpurple:latest` | Base image |
| `ghcr.io/myyc/silverpurple-nvidia:latest` | With Nvidia drivers |

## Rebase

### First time (from stock Silverblue)

Use the unsigned image to get signing policies installed:

```bash
# Base
rpm-ostree rebase ostree-unverified-registry:ghcr.io/myyc/silverpurple:latest

# Nvidia
rpm-ostree rebase ostree-unverified-registry:ghcr.io/myyc/silverpurple-nvidia:latest
```

Reboot, then you're set. Future rebases will use signed verification automatically.

### Subsequent rebases

```bash
# Base
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/myyc/silverpurple:latest

# Nvidia
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/myyc/silverpurple-nvidia:latest
```

## What's included

- RPM Fusion codecs (ffmpeg, mesa-va-drivers-freeworld, mesa-vdpau-drivers-freeworld)
- Terminal: alacritty, fish, tmux, bat, lsd
- Tools: nmap, tcpdump, java-latest-openjdk
- Services: mullvad-vpn, nebula, syncthing, waydroid
- Fonts: google-noto-fonts-all-vf
- Nvidia variant: akmod-nvidia drivers

Removed: firefox (use Flatpak), Fedora Flatpak remote (use Flathub)

## Verification

Images are signed with cosign. Public key: [cosign.pub](cosign.pub)
