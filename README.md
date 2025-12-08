# Silverpurple

A custom set of Silverblue images. The `silverblue-base` image is what Silverblue should be but, for some reason, isn't.

* Codecs
* No Fedora Flatpak
* Firefox from Flatpak
* (`silverblue-base-nvidia` only) Nvidia drivers

These images configure Flathub as a user repo rather than system for the basic reason that most computers nowadays are single-user and either way the change is very easily reversible – even using GNOME Software.

## Images

| Image | Base | Description |
|-------|------|-------------|
| `ghcr.io/myyc/silverpurple-base` | fedora-silverblue | Codecs, Flathub, Firefox |
| `ghcr.io/myyc/silverpurple-base-nvidia` | silverpurple-base | + Nvidia drivers |
| `ghcr.io/myyc/silverpurple` | silverpurple-base | + opinionated config |
| `ghcr.io/myyc/silverpurple-nvidia` | silverpurple-base-nvidia | + opinionated config |

### Opinionated?

Universal Blue, Bazzite etc. they're all nice but we all have a different understanding of what "universal" or "batteries included" should mean. I prefer to flag my additions as weird and opinionated as most of these additions are quite useless to most users but hey, maybe not to you, so just in case, here they are:

- Fonts: JetBrainsMono Nerd Font, google-noto-fonts-all-vf
- Terminal: alacritty, fish, tmux, bat, lsd
- Tools: nmap, tcpdump
- Services: mullvad-vpn, nebula, syncthing
- ntsync kernel module (Wine/Proton compatibility) (*will probably be removed in the future since it might enter mainline Silverblue*)
- GNOME tweaks: VRR, fractional scaling, animations off
- Remmoving pipewire-config-raop which is mostly a source of noise

## Rebase

### First time (from stock Silverblue)

Use the unsigned image to get signing policies installed:

```bash
# Base
rpm-ostree rebase ostree-unverified-registry:ghcr.io/myyc/silverpurple-base:latest

# Base + Nvidia
rpm-ostree rebase ostree-unverified-registry:ghcr.io/myyc/silverpurple-base-nvidia:latest

# Opinionated
rpm-ostree rebase ostree-unverified-registry:ghcr.io/myyc/silverpurple:latest

# Opinionated + Nvidia
rpm-ostree rebase ostree-unverified-registry:ghcr.io/myyc/silverpurple-nvidia:latest
```

Reboot, then you're set. Future upgrades use signed verification automatically.

### Nvidia: blacklist nouveau

After rebasing to an nvidia image, blacklist the nouveau driver:

```bash
rpm-ostree kargs --append=rd.driver.blacklist=nouveau,nova_core --append=modprobe.blacklist=nouveau,nova_core
```

Reboot. On first boot, the `akmods` service will build the nvidia kernel module (this takes a few minutes). After another reboot, nvidia is ready.

## Verification

Images are signed with cosign. Public key: [cosign.pub](cosign.pub)
