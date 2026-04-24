# Post-install runbook — after `startup.sh` prints `STARTUP_SCRIPT_DONE`

This is the manual, click-through checklist the agent walks a user through
once the first-boot install script has finished. Each section is a single
step — the agent must confirm it is done before moving to the next one.

The original, human-facing version of this runbook lives at
`installation/create_dev_machine.md` and stays unchanged for reference.

## 0. Pre-requisite — wait for the startup script

Before starting this runbook, confirm the startup script has finished. SSH
into the new VM and tail the journal:

```bash
gcloud compute ssh <MACHINE_NAME> \
  --project=<PROJECT> \
  --zone=<ZONE> \
  --command='sudo journalctl -u google-startup-scripts.service -f'
```

Wait until you see the marker line:

```text
STARTUP_SCRIPT_DONE
```

Then exit the journal follow with `Ctrl+C` and proceed to step 1.

## 1. Configure Chrome Remote Desktop (CRD)

CRD is installed on the VM but not yet registered to a Google account. This
is the one step that **must** happen over SSH, because the registration
command is a one-time code tied to the user's Chrome profile.

1. On your **laptop** (not the VM), open
   <https://remotedesktop.google.com/headless> in Chrome.
2. Click **Begin → Next → Authorize**.
3. Choose **Debian Linux → Next**. Google shows a one-liner that looks like:

   ```bash
   DISPLAY= /opt/google/chrome-remote-desktop/start-host \
     --code="4/0A..." \
     --redirect-url="https://remotedesktop.google.com/_/oauthredirect" \
     --name=$(hostname)
   ```

4. SSH into the VM as the user who will own the CRD session, paste that
   command, and run it.
5. When prompted, enter a **6-digit PIN** (you'll type this every time you
   connect — not the Google password).
6. Go to <https://remotedesktop.google.com/access> on your laptop. The
   newly registered machine should appear. Click it, enter the PIN, and
   confirm the XFCE desktop loads.

## 2. Disable the XFCE autoscreen lock

XFCE will try to lock the screen after idle. That gets awkward over CRD —
disable it.

1. Inside the CRD session, open **Applications → Settings → Screensaver**.
2. Switch to the **Lock Screen** tab.
3. Untick **Enable Lock Screen**.
4. Close the dialog.

## 3. Create (or import) an SSH key

Used to push to GitHub / GitLab from the dev VM.

### 3a. Fresh key (recommended for a new machine)

```bash
cd ~
mkdir -p .ssh && chmod 700 .ssh
cd .ssh
ssh-keygen -t ed25519 -C "your.address@email.com"
# Accept defaults; set a passphrase.
```

The public key is at `~/.ssh/id_ed25519.pub` — add it to GitHub / GitLab.

### 3b. Import an existing key

Copy the old key's `id_ed25519` (private) and `id_ed25519.pub` (public)
into `~/.ssh/` on the new VM and set permissions:

```bash
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

> Legacy RSA keys still work; newer projects prefer `ed25519`.

## 4. Tweak `~/.bashrc` — show the git branch in the prompt

Open VS Code (or `nano ~/.bashrc`) and append:

```bash
# ---- git-aware prompt ----
git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
# Colourised PS1 with branch on the right.
export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(git_branch)\$ '
```

Reload:

```bash
source ~/.bashrc
```

Close the terminal, open a fresh one, `cd` into a git repo, and confirm
the branch appears in parentheses after the path.

## 5. (Optional) Confirm the editors

Both editors are baseline; neither needs to be installed by the user.

- VS Code:

  ```bash
  code --version
  ```

- Cursor:

  ```bash
  /usr/local/bin/cursor --version
  # or launch it from the XFCE app menu (Development → Cursor).
  ```

If Cursor fails to start with a Chromium sandbox error, edit
`/usr/local/bin/cursor` and add `--no-sandbox` to the `exec` line.

## 6. (Optional) Save a provisioning summary

Offer to write a short record (project, machine name, external IP,
toggles, date) to the `installation/` folder — handy when the user wants
to remember which machine was set up how. Skip if the user declines.

---

**Done.** The VM is now a fully-usable remote dev box. Any later changes
(install more tools, grant more users access, etc.) can be done directly
over SSH.
