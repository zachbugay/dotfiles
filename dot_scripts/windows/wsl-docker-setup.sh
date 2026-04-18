#!/usr/bin/env bash
#
# WSL (Ubuntu) Docker Engine setup.
# Run as root:  sudo ./wsl-docker-setup.sh
#
set -euo pipefail

TARGET_USER="${SUDO_USER:-zacharybugay}"

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (use sudo)." >&2
  exit 1
fi

# Source the file into the current shell so the variables are available.
. /etc/os-release
CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
if [[ -z "$CODENAME" ]]; then
  echo "Could not determine Ubuntu codename." >&2
  exit 1
fi

apt-get update -y
apt-get install -y ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${CODENAME}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt-get update -y
apt-get install -y \
  docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin \
  openssh-server net-tools tldr

mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<'EOF'
{
  "hosts": ["unix:///var/run/docker.sock"]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/override.conf <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --config-file /etc/docker/daemon.json
EOF

# Overwrite /etc/wsl.conf with a known-good config (idempotent).
cat > /etc/wsl.conf <<EOF
[boot]
systemd=true

[user]
default=${TARGET_USER}
EOF

getent group docker >/dev/null || groupadd docker
usermod -aG docker "$TARGET_USER"

# --- Configure SSH to listen on port 2222, instead of 22. This is to ensure Docker CLI access from Windows. --- #
sed -i 's/^#Port22$/Port 2222' /etc/ssh/sshd_config

# --- Enable + start docker (if systemd is active this run) ---------------
systemctl daemon-reload || true
if pidof systemd >/dev/null 2>&1; then
  systemctl enable --now docker ssh
else
  echo "systemd is not active in this WSL session."
  echo "Run 'wsl --shutdown' from Windows, then relaunch WSL to start docker and ssh."
fi

echo "Done. Log out/in (or restart WSL) for docker group membership to apply."
