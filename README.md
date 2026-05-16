# UserLAnd-Next-Assets-debian12

Debian 12 Bookworm rootfs and assets for [UserLAnd-Next](https://github.com/Vodkashot28/UserLAnd).

Includes Python, NumPy, SciPy, and pandas for AI/ML workflows.

## Repo Layout

```
assets/
  assets.txt          # filenames + SHA256 checksums
  *.sh                # UserLAnd helper scripts
README.md
Dockerfile            # reproducible builds
input/
  main.sh             # rootfs build script (debootstrap)
  disableselinux.c    # SELinux disable shim
.github/workflows/
  release.yml         # CI/CD build & release
```

Release artifacts (uploaded to GitHub Releases, not committed):
```
{arch}-rootfs.tar.gz   # rootfs tarball per architecture
{arch}-assets.tar.gz   # helper scripts tarball per architecture
{arch}-assets.txt      # SHA256 manifest per architecture
```

## Supported Architectures

| Arch | Docker platform |
|------|----------------|
| arm64 | linux/arm64 |
| arm | linux/arm/v7 |
| x86_64 | linux/amd64 |
| x86 | linux/386 |

## Building

### Via GitHub Actions
Trigger the `Build and Release Debian 12 Assets` workflow manually with a tag (e.g. `v1.0.0`), or push a `v*` tag.

### Locally with Docker
```bash
docker build --build-arg ARCH=arm64 -t debian12-assets .
```

### Manually
```bash
sudo apt-get install debootstrap
sudo debootstrap --arch=arm64 bookworm ./debian12-rootfs http://deb.debian.org/debian
# install packages inside chroot, then:
tar -C ./debian12-rootfs -czf rootfs-arm64.tar.gz .
```
