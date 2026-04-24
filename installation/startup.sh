#!/usr/bin/env bash
# =============================================================================
# startup.sh — GCP Compute dev machine first-boot install script
# -----------------------------------------------------------------------------
# Runs as root once on first boot via the VM's `startup-script` metadata.
# Tail it while it is running:
#     sudo journalctl -u google-startup-scripts.service -f
# When it finishes you will see the marker line:
#     STARTUP_SCRIPT_DONE
#
# Toggles — set to "true" or "false" before the script is attached to the VM.
# The create-dev-machine.sh wrapper substitutes the placeholders below.
# VS Code and Cursor are BASELINE — always installed, no toggle.
# =============================================================================

set -eo pipefail

# ---- Toggles ----------------------------------------------------------------
INSTALL_NODE_STACK="${INSTALL_NODE_STACK:-__INSTALL_NODE_STACK__}"
INSTALL_PYTHON_DEV="${INSTALL_PYTHON_DEV:-__INSTALL_PYTHON_DEV__}"
INSTALL_JQ="${INSTALL_JQ:-__INSTALL_JQ__}"
INSTALL_FLUTTER="${INSTALL_FLUTTER:-__INSTALL_FLUTTER__}"

# ---- Versions ---------------------------------------------------------------
NODE_MAJOR="${NODE_MAJOR:-24}"
NVM_VERSION="${NVM_VERSION:-0.40.1}"

# ---- Non-interactive apt ----------------------------------------------------
export DEBIAN_FRONTEND=noninteractive

log() { printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }

# =============================================================================
# 0. Baseline — apt refresh, upgrade, and common tooling
# =============================================================================
log "Updating apt indexes and upgrading packages"
apt-get update -y
apt-get upgrade -y

log "Installing baseline packages"
apt-get install -y \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg \
    unzip \
    git \
    python3 \
    python3-pip

# =============================================================================
# 1. Remote-desktop GUI bundle — Chrome Remote Desktop + XFCE + XScreenSaver
# =============================================================================
log "Installing Chrome Remote Desktop"
wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb \
    -O /tmp/chrome-remote-desktop.deb
apt-get install -y /tmp/chrome-remote-desktop.deb
rm -f /tmp/chrome-remote-desktop.deb

log "Installing XFCE desktop environment"
apt-get install -y xfce4 xfce4-goodies desktop-base

log "Configuring Chrome Remote Desktop to launch XFCE"
echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" \
    > /etc/chrome-remote-desktop-session

log "Installing XScreenSaver (Light Locker is incompatible with CRD)"
apt-get install -y xscreensaver

log "Disabling lightdm — no physical display is attached"
systemctl disable lightdm.service || true

# =============================================================================
# 2. Browsers — Firefox + Google Chrome
# =============================================================================
log "Installing Firefox (snap)"
snap install firefox || apt-get install -y firefox

log "Installing Google Chrome"
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    -O /tmp/google-chrome.deb
apt-get install -y /tmp/google-chrome.deb
rm -f /tmp/google-chrome.deb

# =============================================================================
# 3. Cloud CLIs — gcloud + AWS CLI
# =============================================================================
log "Installing Google Cloud SDK (signed-by keyring)"
install -d -m 0755 /usr/share/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    > /etc/apt/sources.list.d/google-cloud-sdk.list
apt-get update -y
apt-get install -y google-cloud-sdk

log "Installing AWS CLI v2"
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
(cd /tmp && unzip -q awscliv2.zip && ./aws/install)
rm -rf /tmp/awscliv2.zip /tmp/aws

# =============================================================================
# 4. Editors — VS Code + Cursor (baseline, always installed)
# =============================================================================

# 4a. VS Code (snap, classic) --------------------------------------------------
log "Installing VS Code (snap, classic)"
snap install --classic code

# 4b. Cursor (AI code editor) --------------------------------------------------
# Cursor ships as an AppImage. We install libfuse2t64 (needed by AppImages on
# Ubuntu 24.04+) AND extract the AppImage to /opt/cursor so runtime does not
# depend on FUSE at all. The wrapper at /usr/local/bin/cursor runs the
# extracted AppRun. A .desktop file registers it in the XFCE application menu.
log "Installing Cursor AI editor"
apt-get install -y libfuse2t64 || apt-get install -y libfuse2 || true
curl -fsSL "https://downloader.cursor.sh/linux/appImage/x64" -o /tmp/cursor.AppImage
chmod +x /tmp/cursor.AppImage
install -d /opt/cursor
(cd /opt/cursor && /tmp/cursor.AppImage --appimage-extract >/dev/null)
chmod -R a+rX /opt/cursor/squashfs-root
cat > /usr/local/bin/cursor <<'CURSOR_WRAPPER'
#!/usr/bin/env bash
# If Cursor fails on this VM with a Chromium sandbox error, add --no-sandbox:
#   exec /opt/cursor/squashfs-root/AppRun --no-sandbox "$@"
exec /opt/cursor/squashfs-root/AppRun "$@"
CURSOR_WRAPPER
chmod +x /usr/local/bin/cursor
cat > /usr/share/applications/cursor.desktop <<'CURSOR_DESKTOP'
[Desktop Entry]
Name=Cursor
Comment=AI-first code editor
Exec=/usr/local/bin/cursor %F
Icon=/opt/cursor/squashfs-root/resources/app/resources/linux/cursor.png
Terminal=false
Type=Application
Categories=Development;IDE;TextEditor;
StartupWMClass=Cursor
MimeType=text/plain;inode/directory;application/x-code-workspace;
CURSOR_DESKTOP
rm -f /tmp/cursor.AppImage

# =============================================================================
# 5. Dev toolchain — individually toggled
# =============================================================================

# 5a. Python development headers ----------------------------------------------
if [ "$INSTALL_PYTHON_DEV" = "true" ]; then
    log "Installing Python development headers + build tooling"
    apt-get install -y \
        python3-dev \
        default-libmysqlclient-dev \
        build-essential \
        pkg-config
else
    log "Skipping Python dev headers (INSTALL_PYTHON_DEV=$INSTALL_PYTHON_DEV)"
fi

# 5b. Node.js stack (Node + npm + yarn + nvm) ---------------------------------
if [ "$INSTALL_NODE_STACK" = "true" ]; then
    log "Installing Node.js ${NODE_MAJOR}.x from NodeSource"
    install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list
    apt-get update -y
    apt-get install -y nodejs

    log "Upgrading npm and installing yarn globally"
    npm install --global npm@latest
    npm install --global yarn

    log "Installing nvm ${NVM_VERSION} for all human users"
    export NVM_DIR=/usr/local/nvm
    mkdir -p "$NVM_DIR"
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash
    cat > /etc/profile.d/nvm.sh <<'NVM_EOF'
export NVM_DIR=/usr/local/nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
NVM_EOF
    chmod 0644 /etc/profile.d/nvm.sh
else
    log "Skipping Node.js stack (INSTALL_NODE_STACK=$INSTALL_NODE_STACK)"
fi

# 5c. jq -----------------------------------------------------------------------
if [ "$INSTALL_JQ" = "true" ]; then
    log "Installing jq"
    apt-get install -y jq
else
    log "Skipping jq (INSTALL_JQ=$INSTALL_JQ)"
fi

# 5d. Flutter ------------------------------------------------------------------
if [ "$INSTALL_FLUTTER" = "true" ]; then
    log "Installing Flutter (snap, classic)"
    snap install flutter --classic
else
    log "Skipping Flutter (INSTALL_FLUTTER=$INSTALL_FLUTTER)"
fi

# =============================================================================
# Done.
# =============================================================================
log "STARTUP_SCRIPT_DONE"
