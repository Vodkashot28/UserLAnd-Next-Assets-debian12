#!/bin/bash
set -e

echo "127.0.0.1 localhost" > /etc/hosts
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# UserLAnd environment setup
cat > /etc/profile.d/userland.sh << 'EOF'
#!/bin/sh
unset LD_PRELOAD
unset LD_LIBRARY_PATH
export LIBGL_ALWAYS_SOFTWARE=1
EOF
chmod +x /etc/profile.d/userland.sh

apt-get update

# Base UserLAnd packages
apt-get install -y --no-install-recommends \
  sudo dropbear libgl1 libglx-mesa0 \
  tightvncserver xterm xfonts-base twm expect wget curl

apt-get install -y pulseaudio

# AI/ML packages
apt-get install -y --no-install-recommends \
  python3 python3-pip python3-venv \
  python3-numpy python3-scipy python3-pandas

apt-get clean

# Package rootfs
tar -czvf /output/rootfs.tar.gz \
  --exclude sys --exclude dev --exclude proc --exclude mnt \
  --exclude etc/mtab --exclude output --exclude input --exclude .dockerenv /

# Build libdisableselinux
apt-get update
apt-get install -y build-essential
gcc -shared -fpic /input/disableselinux.c -o /output/libdisableselinux.so

# Grab static busybox
apt-get install -y busybox-static
cp /bin/busybox /output/busybox
