# AGENTS.md — `installation/` scripts

Contract for any AI agent (Claude, Codex, Cursor, Gemini, etc.) operating in
this folder of the `utils` repository. Human-readable too; treat it as the
entry point.

## 1. Purpose

This folder stores reusable installation scripts for Linux development
machines, primarily targeting **GCP Compute Engine VMs running Ubuntu**.

The two main scripts agents should know about are:

- `create-dev-machine.sh` — the provisioning wrapper. Reserves a static IP,
  creates a Spot VM, and attaches a rendered `startup.sh` as the VM's
  `startup-script` metadata.
- `startup.sh` — the first-boot install script. Baseline installs run
  unconditionally; tool-specific sections are gated by `INSTALL_*` toggle
  placeholders that `create-dev-machine.sh` substitutes at render time.

Older topic-specific scripts (`basic-dev-machine.sh`,
`flutter-dev-machine.sh`, `golang-dev-machine.sh`, `mysql-dev-machine.sh`,
`node-js-dev-machine.sh`, `python-dev-machine.sh`,
`terraform-dev-machine.sh`, `tutorial-dev-machine.sh`,
`vue-dev-machine.sh`) are preserved as-is for reference and for anyone
who prefers a single-purpose script over the toggle-driven builder.

## 2. Session startup

On every new chat session, **before** answering any request:

1. List the directories under `.agents/skills/`.
2. For each skill, read ONLY the YAML front matter of its `SKILL.md`.
3. Read the full `SKILL.md` only when you actually invoke that skill.
4. Do not propose plans or touch files until all skill front matter has
   been loaded.

## 3. Local skills

Skills live in `.agents/skills/<name>/`. Each skill has a `SKILL.md` with
MAGI-compliant front matter, plus optional `references/` (long-form docs
the skill reads on demand).

Current skills:

| Skill                     | Purpose (1-liner)                                            |
|---------------------------|--------------------------------------------------------------|
| `gcp-dev-machine-builder` | **Provision a GCP Compute dev VM (this folder's focus).**    |

## 4. Building a dev machine on GCP Compute

Invoke the `gcp-dev-machine-builder` skill any time a user asks for a
development VM on Google Cloud.

### What the skill does

- Runs a one-question-at-a-time interactive intake (project, name,
  region/zone, machine type, disk size, Ubuntu image, Spot vs on-demand).
- Asks per-tool install toggles — Node.js stack, Python dev headers,
  jq, Flutter.
- Always installed (baseline, no toggle): Chrome Remote Desktop + XFCE,
  Firefox + Chrome, gcloud + AWS CLI, and BOTH code editors — VS Code
  (snap) and Cursor (AppImage extracted to `/opt/cursor`, wrapper at
  `/usr/local/bin/cursor`, XFCE application-menu entry).
- Calls `./create-dev-machine.sh` with the collected flags. That script
  renders `./startup.sh` on the fly (toggle placeholders → concrete
  values) and attaches it as the VM's `startup-script` metadata.
- Walks the user through the post-install runbook at
  `.agents/skills/gcp-dev-machine-builder/references/post-install-runbook.md`
  (Chrome Remote Desktop PIN, SSH key, autoscreen-lock, `.bashrc` tweaks).

For a minute-by-minute guide to running the skill from Google Cloud Shell
Editor using Gemini CLI or Gemini Code Assist agent mode, see
`.agents/skills/gcp-dev-machine-builder/references/cloud-shell-gemini-walkthrough.md`.

### Execution model

The agent executes `create-dev-machine.sh` directly in the shell. If
`gcloud` is missing or unauthenticated in that shell, the agent falls
back to writing a fully-parameterized command to
`run-create-dev-machine.sh` in the folder root and hands the user a
ready-to-run instruction for their own terminal. See the SKILL.md for
the exact handoff rules.

### Defaults

| Parameter       | Default                   |
|-----------------|---------------------------|
| Region / zone   | `asia-southeast1` / `-a`  |
| Machine type    | `n1-standard-2`           |
| Disk size       | `200GB`                   |
| Image           | `ubuntu-2404-lts-amd64`   |
| Provisioning    | SPOT                      |
| Toggles         | All `false` by default — agent must ask the user |

### Invocation examples

Trigger phrases that should route to the skill:

- "Create a new GCP dev machine."
- "Spin up a Compute VM I can use for development."
- "Build a remote dev environment on GCP."
- "I want to run `create-dev-machine.sh`."

### Direct (non-agent) script usage

Power users can bypass the agent and run the script themselves:

```bash
bash ./create-dev-machine.sh \
  --project my-gcp-project \
  --name   fbo-dev-01 \
  --with-node       true \
  --with-python-dev false \
  --with-jq         false \
  --with-flutter    false
# VS Code + Cursor are baseline — installed on every machine, no flags.
```

Add `--dry-run` to render the startup script and pass pre-flight without
creating any GCP resources. Add `--help` for the full flag list.

## 5. Files an agent should never touch without asking

- `create_dev_machine.md` — original human-facing runbook. The modernised
  agent-oriented version lives at
  `.agents/skills/gcp-dev-machine-builder/references/post-install-runbook.md`.
  Edits to `create_dev_machine.md` should only happen by explicit user
  request.
- `README.md` — repository-level documentation; confirm with the user
  before editing.
- The topic-specific `*-dev-machine.sh` scripts (golang, python,
  terraform, mysql, node-js, vue, flutter, tutorial, basic). These are
  standalone references; do not modify without explicit user request.
- `.agents/skills/*/SKILL.md` — skill authoring is a deliberate act;
  confirm with the user first.
