#!/bin/bash
set -e

# Map CI arch names to Debian arch names
case "${ARCH:-arm64}" in
  x86_64) DEB_ARCH=amd64 ;;
  arm)    DEB_ARCH=armhf ;;
  arm64)  DEB_ARCH=arm64 ;;
  x86)    DEB_ARCH=i386  ;;
  *)      DEB_ARCH=${ARCH:-arm64} ;;
esac
ROOTFS_DIR=/tmp/debian12-rootfs

# Install debootstrap
apt-get update -qq
apt-get install -y --no-install-recommends debootstrap

# Build minimal Debian 12 rootfs
debootstrap --arch=${DEB_ARCH} --variant=minbase bookworm ${ROOTFS_DIR} http://deb.debian.org/debian

# Add AI/ML packages inside chroot
chroot ${ROOTFS_DIR} /bin/bash -c "
  apt-get update
  apt-get install -y --no-install-recommends \
    sudo dropbear libgl1 libglx-mesa0 \
    tightvncserver xterm xfonts-base twm expect wget curl \
    pulseaudio \
    python3 python3-pip python3-venv \
    python3-numpy python3-scipy python3-pandas
  apt-get clean
  rm -rf /var/lib/apt/lists/*
"

# UserLAnd environment setup
cat > ${ROOTFS_DIR}/etc/profile.d/userland.sh << 'EOF'
#!/bin/sh
unset LD_PRELOAD
unset LD_LIBRARY_PATH
export LIBGL_ALWAYS_SOFTWARE=1
EOF
chmod +x ${ROOTFS_DIR}/etc/profile.d/userland.sh

echo "127.0.0.1 localhost" > ${ROOTFS_DIR}/etc/hosts
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > ${ROOTFS_DIR}/etc/resolv.conf

# Bundle rootfs
tar -C ${ROOTFS_DIR} -czf /output/rootfs.tar.gz \
  --exclude=sys --exclude=dev --exclude=proc \
  --exclude=etc/mtab .

# Build libdisableselinux
apt-get install -y --no-install-recommends build-essential
gcc -shared -fpic /input/disableselinux.c -o /output/libdisableselinux.so

# Grab static busybox
apt-get install -y --no-install-recommends busybox-static
cp /bin/busybox /output/busybox

