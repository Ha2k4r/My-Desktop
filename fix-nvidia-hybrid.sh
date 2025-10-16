#!/bin/bash
# Fix NVIDIA 470xx hybrid setup for Intel + Kepler on Arch Linux (Hyprland compatible)

set -e

echo "===> Checking for yay..."
if ! command -v yay &>/dev/null; then
    echo "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd ~
fi

echo "===> Installing necessary packages..."
sudo pacman -S --needed --noconfirm dkms mesa-utils egl-wayland
yay -S --needed --noconfirm nvidia-470xx-dkms nvidia-470xx-utils lib32-nvidia-470xx-utils

echo "===> Rebuilding NVIDIA DKMS module..."
sudo dkms autoinstall

echo "===> Verifying NVIDIA kernel module..."
KERNEL=$(uname -r)
if [ ! -d "/lib/modules/$KERNEL/extra" ]; then
    echo "No /lib/modules/$KERNEL/extra directory found — DKMS may have failed."
    exit 1
fi

echo "===> Creating modprobe configuration..."
sudo tee /etc/modprobe.d/nvidia.conf >/dev/null <<EOF
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_UsePageAttributeTable=1
options nvidia_drm modeset=1 fbdev=1
EOF

echo "===> Adding NVIDIA modules to mkinitcpio.conf..."
sudo sed -i '/^MODULES=/c\MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' /etc/mkinitcpio.conf
sudo mkinitcpio -P

echo "===> Updating GRUB kernel parameters..."
if grep -q "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& nvidia_drm.modeset=1 nvidia_drm.fbdev=1/' /etc/default/grub
else
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet nvidia_drm.modeset=1 nvidia_drm.fbdev=1"' | sudo tee -a /etc/default/grub
fi
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "===> Creating prime-run script..."
sudo tee /usr/bin/prime-run >/dev/null <<'EOF'
#!/bin/bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"
EOF
sudo chmod +x /usr/bin/prime-run

echo "===> Creating environment config..."
sudo tee /etc/environment >/dev/null <<EOF
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
EOF

echo "===> Enabling nvidia-persistenced service..."
sudo systemctl enable --now nvidia-persistenced.service || true

echo "===> DKMS and module build complete."
echo "You should now reboot to load the driver."

read -p "run nvidia-smi on reboot. Reboot now? (Y/n): " ans
if [[ "$ans" =~ ^[Yy]$ || -z "$ans" ]]; then
    sudo reboot
else
    echo "Reboot skipped. Run 'sudo reboot' later. Also be sure to confirm this works with : nvidia-smi"
fi
