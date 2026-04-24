# Cloud Shell + Gemini walkthrough — driving the skill end-to-end

Step-by-step guide to running the `gcp-dev-machine-builder` skill from
**Google Cloud Shell Editor** using either the **Gemini CLI** (terminal)
or **Gemini Code Assist** agent mode (editor sidebar).

Audience: any user with a GCP account and a laptop. No local
installation required — Cloud Shell comes pre-configured with `gcloud`,
`git`, `node`, `python3`, and the Gemini CLI.

---

## Part A — Pre-requisites (≈ 2 min)

1. A Google account with access to at least one **billing-enabled GCP
   project**.
2. Your key in GitHub (public SSH key) so you can push/pull from the
   dev VM once it is up. This is not strictly needed to **create** the
   VM — skip if you just want the box running.
3. A browser (Chrome recommended, Firefox works too).

> If the `utils` repo is public, you don't need any extra access — you
> can clone it read-only from Cloud Shell in Part C.

---

## Part B — Open Cloud Shell Editor (≈ 1 min)

1. Go to <https://shell.cloud.google.com/?show=terminal,ide> in a new
   tab. (This URL opens the terminal + IDE side-by-side.)
2. Sign in with the Google account tied to your GCP project.
3. If prompted, click **Authorize** to let Cloud Shell use your
   credentials.
4. When the editor loads, make sure the **Terminal** panel is open at the
   bottom — if not, **View → Terminal** (or `` Ctrl+` ``).

What you see:

- Left sidebar → the Cloud Shell file explorer (persistent `$HOME` on
  Cloud Shell's 5 GB disk).
- Centre → Cloud Shell Editor (an online VS Code).
- Right sidebar → a **Gemini** icon (sparkles). Click it to open Gemini
  Code Assist chat.
- Bottom → a bash terminal.

---

## Part C — Clone the `utils` repo (≈ 1 min)

In the terminal:

```bash
cd ~
git clone https://github.com/<your-github-user>/utils.git
cd utils/installation
ls -la
```

You should see `create-dev-machine.sh`, `startup.sh`, `AGENTS.md`, and
the `.agents/skills/gcp-dev-machine-builder/` folder.

> If your repo is a fork of someone else's `utils`, replace the URL
> accordingly.

In the editor sidebar, click **File → Open Folder…** and select
`~/utils/installation`. This makes `AGENTS.md` and the skill discoverable
by Gemini Code Assist agent mode.

---

## Part D — Confirm `gcloud` is ready (≈ 30 s)

Cloud Shell is already authenticated for your Google account, but it
may default to a project you do not want. Double-check:

```bash
gcloud auth list --filter=status:ACTIVE --format='value(account)'
gcloud config list project
```

If the listed project is wrong, change it:

```bash
gcloud config set project <YOUR_PROJECT_ID>
```

> You'll still pass `--project` explicitly in Part F; setting it here
> just keeps the default sane.

---

## Part E — Pick your Gemini flavour

You have two equivalent options. Pick one.

### E1. Gemini CLI in the terminal (no IDE interaction)

Verify it is installed:

```bash
gemini --version
```

If missing (it shouldn't be), install:

```bash
npm install -g @google/gemini-cli
```

Start an interactive session from the `installation/` folder:

```bash
cd ~/utils/installation
gemini
```

The CLI reads `AGENTS.md` and the skills under `.agents/skills/`
automatically — they are its context.

### E2. Gemini Code Assist (agent mode) in the sidebar

1. Click the **Gemini** sparkles icon in the right sidebar of the
   editor.
2. If prompted, **Enable Gemini Code Assist** — free tier works.
3. At the top of the chat panel, look for a mode toggle. Select
   **Agent** (not "Chat"). Agent mode gives Gemini tool access —
   reading files, running shell commands, editing files.
4. Confirm the current workspace is `~/utils/installation` (shown in the
   editor title bar).

Agent mode reads `AGENTS.md` automatically when you open the folder.

---

## Part F — Ask Gemini to build the machine (≈ 3 min of Q&A)

Type, in either the Gemini CLI prompt or the Code Assist agent chat:

```text
I want to create a new GCP dev machine.
```

What happens next:

1. **Pre-flight.** Gemini reads `AGENTS.md`, then
   `.agents/skills/gcp-dev-machine-builder/SKILL.md`, and confirms
   `create-dev-machine.sh` + `startup.sh` exist.
2. **Intake.** Gemini asks, one at a time:
   - GCP project ID (no default).
   - Machine name (no default; lowercase letters, digits, hyphens; max
     63 chars; starts with a letter).
   - Region (default `asia-southeast1`).
   - Zone (default `asia-southeast1-a`).
   - Machine type (default `n1-standard-2`).
   - Boot disk size (default `200GB`).
   - Ubuntu image (default `ubuntu-2404-lts-amd64`).
   - Provisioning model — Spot (cheap, preemptible) or on-demand.
   - Node.js stack? (yes/no).
   - Python dev headers? (yes/no).
   - jq? (yes/no).
   - Flutter? (yes/no).

   VS Code + Cursor are baseline — always installed, no question.

3. **Confirmation.** Gemini prints a summary and the final command, e.g.:

   ```bash
   bash ./create-dev-machine.sh \
     --project my-project \
     --name    fbo-dev-01 \
     --region  asia-southeast1 \
     --zone    asia-southeast1-a \
     --machine-type   n1-standard-2 \
     --disk-size      200GB \
     --image-family   ubuntu-2404-lts-amd64 \
     --image-project  ubuntu-os-cloud \
     --with-node       true \
     --with-python-dev false \
     --with-jq         false \
     --with-flutter    false
   ```

   Answer **"yes"** (or "proceed" / "run it") to execute.

4. **Execution.** Gemini runs the script. You will see:
   - Pre-flight log lines ("Using gcloud account: …", "Project '…' is
     accessible", toggle summary).
   - The rendered startup script's path.
   - `Reserving static external IP '<NAME>-ip' in region '<REGION>'`.
   - `Creating Compute instance '<NAME>' in zone '<ZONE>' (SPOT)`.
   - `Instance created. External IP: <address>`.
   - A block of "Next step" instructions pointing at the post-install
     runbook.

> If any pre-flight check fails, Gemini surfaces the error line and
> offers to retry after you fix it. Common first-time issues: project
> not accessible (missing IAM), machine name already taken, IP quota
> exceeded.

---

## Part G — Watch the startup script finish (≈ 5–15 min)

The VM exists within ~30 seconds, but the baseline + toggled installs
take 5–15 minutes. In the same Cloud Shell terminal:

```bash
gcloud compute ssh <MACHINE_NAME> \
  --project=<PROJECT> \
  --zone=<ZONE> \
  --command='sudo journalctl -u google-startup-scripts.service -f'
```

Wait for the marker line:

```text
STARTUP_SCRIPT_DONE
```

Press `Ctrl+C` once you see it.

> While you wait, you can ask Gemini to summarise what was provisioned
> or to open `references/post-install-runbook.md` so you can read ahead.

---

## Part H — Post-install walkthrough (≈ 5 min)

Tell Gemini:

```text
Walk me through the post-install runbook.
```

Gemini opens
`.agents/skills/gcp-dev-machine-builder/references/post-install-runbook.md`
and walks through each section, asking for confirmation before moving
on:

1. Wait for `STARTUP_SCRIPT_DONE` (already done).
2. Register Chrome Remote Desktop, set a 6-digit PIN.
3. Disable the XFCE autoscreen lock.
4. Create or import an SSH key (ed25519 recommended).
5. Tweak `~/.bashrc` to show the git branch in the prompt.
6. Confirm VS Code / Cursor launch from the XFCE application menu.

At the end, Gemini offers to save a short summary (project / name / IP /
toggles / date) to the `installation/` folder.

---

## Part I — Stopping / starting / deleting the VM

### Stop (pause the machine, stops billing for CPU/RAM but not disk/IP):

```bash
gcloud compute instances stop <MACHINE_NAME> \
  --project=<PROJECT> --zone=<ZONE>
```

### Start (resume the machine — note the external IP is preserved because
we reserved it):

```bash
gcloud compute instances start <MACHINE_NAME> \
  --project=<PROJECT> --zone=<ZONE>
```

### Delete the VM and release the static IP (full tear-down):

```bash
gcloud compute instances delete <MACHINE_NAME> \
  --project=<PROJECT> --zone=<ZONE>
gcloud compute addresses delete <MACHINE_NAME>-ip \
  --project=<PROJECT> --region=<REGION>
```

> Ask Gemini `how do I tear down the machine?` and it will ask you for
> the name and run these for you after confirmation.

---

## Part J — Troubleshooting

| Symptom                                                | Likely cause                                       | Fix                                                                                                |
|--------------------------------------------------------|----------------------------------------------------|----------------------------------------------------------------------------------------------------|
| `gcloud: command not found` in Cloud Shell             | You are not in Cloud Shell — you are in a browser sandbox. | Reopen <https://shell.cloud.google.com/>.                                                          |
| `ERROR: (gcloud.compute.addresses.create) …` → quota   | Your project has hit the regional IP quota.        | Release an unused address or pick another region.                                                  |
| Startup script never prints `STARTUP_SCRIPT_DONE`      | A package install hit a transient network error.   | SSH in, run `sudo journalctl -u google-startup-scripts.service` and look for the failed apt/snap command. Re-run it manually. |
| Chrome Remote Desktop page says "Machine offline"      | VM stopped, or CRD service crashed.                | `gcloud compute instances start …`, then `sudo systemctl status chrome-remote-desktop@$(whoami)`.  |
| Cursor fails to launch with "SUID sandbox helper" error | Chromium sandbox disabled by host kernel.          | Edit `/usr/local/bin/cursor` and add `--no-sandbox` to the `exec` line.                            |
| Gemini agent does not see `.agents/skills/`            | You opened the wrong folder in the editor.         | **File → Open Folder…** and select `~/utils/installation`.                                         |

---

## Appendix — Running the skill from your own laptop instead

Everything above works from **any** shell with `gcloud` installed and
authenticated, not just Cloud Shell. If you prefer your laptop:

1. Install gcloud: <https://cloud.google.com/sdk/docs/install>.
2. `gcloud auth login` (browser popup).
3. `gcloud config set project <YOUR_PROJECT_ID>`.
4. Clone the repo and `cd utils/installation`.
5. Run Gemini CLI (`gemini`) or your preferred agent that honours
   `AGENTS.md` (Claude Code, Codex, Cursor agent mode, Windsurf, etc.).
6. Say "create a new GCP dev machine" and follow the same Part F
   intake.

The skill is environment-agnostic — Cloud Shell is just the **zero-setup**
path.
