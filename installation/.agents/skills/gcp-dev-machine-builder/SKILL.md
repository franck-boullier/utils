---
name: gcp-dev-machine-builder
description: Provisions a GCP Compute Engine dev VM tailored to the user's needs. Baseline install always includes Chrome Remote Desktop + XFCE, Firefox + Chrome, gcloud + AWS CLI, and BOTH code editors — VS Code (snap) and Cursor (AppImage extracted to /opt/cursor). The agent runs an interactive one-question-at-a-time intake (project, machine name, region/zone, machine type, disk, Spot vs on-demand, and per-tool toggles for Node / Python dev headers / jq / Flutter) and then invokes `../../../create-dev-machine.sh` with the collected values. If `gcloud` is unavailable or unauthenticated in the current shell, the agent renders the final startup script to the folder and hands the user a ready-to-run command instead. Triggers on phrases like "create a dev machine", "spin up a GCP dev VM", "provision a Compute instance for development", "new remote dev environment on GCP", or direct mentions of `create-dev-machine.sh` or `create_dev_machine.md`. Does NOT trigger for production infrastructure, Kubernetes clusters, or non-GCP clouds.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
version: "1.1.0"
doc-id: 5979d7ff-17ea-407a-90c1-0a23279fa219
title: GCP Dev Machine Builder
purpose: guide
audience: ai-agent
last-updated: "2026-04-24"
tags:
  - gcp
  - compute-engine
  - dev-environment
  - vm-provisioning
  - chrome-remote-desktop
  - spot-instance
  - devops
key_concepts:
  - interactive-intake
  - startup-script-templating
  - toggle-driven-install
  - preflight-validation
  - graceful-local-handoff
---

# GCP Dev Machine Builder

Helps the user stand up a GCP Compute Engine VM configured as a personal
development environment. The skill references two scripts (one level up
from the skill folder, at the root of `installation/`) and ships two
long-form references of its own:

- `../../../create-dev-machine.sh` — provisioning wrapper (static IP + Spot VM).
- `../../../startup.sh` — first-boot install script with placeholder toggles.
- `references/post-install-runbook.md` — manual post-boot steps (Chrome Remote
  Desktop registration, SSH key, `.bashrc` tweaks, autoscreen-lock disable).
- `references/cloud-shell-gemini-walkthrough.md` — minute-by-minute guide for
  driving this skill from Google Cloud Shell Editor using Gemini CLI or
  Gemini Code Assist agent mode.

## When to use this skill

- The user asks to create, spin up, provision, or rebuild a GCP dev VM.
- The user references `create-dev-machine.sh`, `startup.sh`, or
  `create_dev_machine.md`.
- The user wants a remote dev box they can reach via Chrome Remote Desktop.

## When NOT to use this skill

- Production infrastructure provisioning → use the generic DevOps skill.
- Anything on AWS, Azure, on-prem, or Kubernetes.
- Modifying an already-running dev VM (just SSH in — no provisioning needed).

## Workflow

### Phase 1 — Pre-flight

Before asking the user any questions:

1. Confirm the skill's own files and the scripts exist, resolving relative
   to this SKILL.md:
   - `../../../create-dev-machine.sh`
   - `../../../startup.sh`
   - `references/post-install-runbook.md`
2. Run `command -v gcloud && gcloud auth list --filter=status:ACTIVE --format='value(account)'`
   to see whether the current shell can execute the provisioning.
   - If `gcloud` is missing or no active account exists, remember this —
     you will switch to the "local handoff" path in Phase 3.

### Phase 2 — Intake (one question at a time)

Use the `AskUserQuestion` tool. Collect values in this order, and ALWAYS
confirm the full parameter set before moving on.

1. **GCP project ID** — no default; ask the user.
2. **Machine name** — no default; validate against the GCE regex
   `^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$`. If invalid, ask again.
3. **Region** — default `asia-southeast1`. Offer "keep default / pick another".
4. **Zone** — default `asia-southeast1-a`. Must sit inside the chosen region.
5. **Machine type** — default `n1-standard-2`. Offer common alternatives
   (`e2-standard-2`, `n2-standard-4`) plus "Other".
6. **Boot-disk size** — default `200GB`.
7. **Ubuntu image** — default `ubuntu-2404-lts-amd64`
   (project: `ubuntu-os-cloud`). Offer `ubuntu-2204-lts` as alternative.
8. **Provisioning model** — default `SPOT` (cheapest). Offer on-demand for
   long-running jobs that cannot tolerate preemption.
9. **Dev-toolchain toggles**, one yes/no per tool, in this order:
   - Node.js stack — Node + npm + yarn + nvm (`--with-node`)
   - Python dev headers + build tooling (`--with-python-dev`)
   - jq (`--with-jq`)
   - Flutter (`--with-flutter`)

   VS Code and Cursor are baseline — always installed, no toggle.

After all answers are in, summarise the full configuration and the final
command you are about to run. Wait for the user's explicit confirmation.

### Phase 3 — Execute or hand off

#### Path A — gcloud is available and authenticated

Run the script from the `installation/` folder (one level up from
`.agents/`, three levels up from this SKILL.md):

```bash
bash ./create-dev-machine.sh \
  --project "<PROJECT>" \
  --name "<NAME>" \
  --region "<REGION>" \
  --zone "<ZONE>" \
  --machine-type "<TYPE>" \
  --disk-size "<DISK>" \
  --image-family "<FAMILY>" \
  --image-project "<IMAGE_PROJECT>" \
  --with-node <true|false> \
  --with-python-dev <true|false> \
  --with-jq <true|false> \
  --with-flutter <true|false>
```

Add `--on-demand` only if the user picked the STANDARD provisioning model.

Stream the output back to the user. On failure, show the error verbatim
and offer to retry (after the user fixes the underlying issue).

#### Path B — local handoff

If pre-flight told you `gcloud` is missing or unauthenticated:

1. Write the fully-parameterized command to a file at the `installation/`
   root called `run-create-dev-machine.sh` (one-liner, executable).
2. Tell the user exactly:
   - Where the script is.
   - That they need `gcloud` installed and `gcloud auth login` run locally.
   - The command to run: `bash run-create-dev-machine.sh`.
3. Do NOT attempt to install `gcloud` in the sandbox — state will not
   persist across sessions.

### Phase 4 — Post-install walkthrough

Once Phase 3 reports success (or the user confirms the local run succeeded):

1. Read `references/post-install-runbook.md`.
2. Walk the user through each numbered section. One question per confirmation
   ("Have you completed step N? y/n"). Do NOT skip to the next step until the
   current one is confirmed.
3. At the end, offer to write a short summary of what was provisioned to the
   folder (project / name / IP / toggles / date).

## Parameter reference

Defaults baked into `create-dev-machine.sh`:

| Parameter     | Default                   | Flag                |
|---------------|---------------------------|---------------------|
| Region        | `asia-southeast1`         | `--region`          |
| Zone          | `asia-southeast1-a`       | `--zone`            |
| Machine type  | `n1-standard-2`           | `--machine-type`    |
| Disk size     | `200GB`                   | `--disk-size`       |
| Image family  | `ubuntu-2404-lts-amd64`   | `--image-family`    |
| Image project | `ubuntu-os-cloud`         | `--image-project`   |
| Provisioning  | SPOT                      | `--on-demand` flips |

Toggle flags default to `false` — the agent MUST pass explicit `true`/`false`
for each based on user answers.

## Rules

- ALWAYS ask before provisioning. Never run `create-dev-machine.sh` without
  a final explicit confirmation.
- NEVER hard-code project IDs or machine names in commits. All values come
  from the user at runtime.
- NEVER invoke `gcloud auth login` from the sandbox — it is interactive and
  credentials do not persist.
- If the user asks to "just use defaults", read the defaults back verbatim
  first and still get one confirmation before executing.
- If `create-dev-machine.sh --dry-run` is supported — it is — prefer a dry
  run first when the user seems uncertain about any parameter.
- If the script fails after the static IP is reserved but before the
  instance is created, the reserved address still counts toward project
  quota. Tell the user and offer to release it with
  `gcloud compute addresses delete <NAME>-ip --region=<REGION>`.

## Example session (abbreviated)

> User: "I need a new GCP dev machine."
>
> Agent: pre-flight passes. Asks Q1 (project). User answers.
>        Asks Q2 (name). User answers `fbo-dev-01`.
>        Asks Q3 (region). User: "keep default".
>        …continues through all questions…
>        Asks the 4 toggles (yes to Node; no to the rest).
>        Summarises:
>          Project: strymin-dev-2026
>          Name: fbo-dev-01
>          Region/zone: asia-southeast1 / asia-southeast1-a
>          Machine: n1-standard-2, 200GB, Ubuntu 24.04, SPOT
>          Baseline editors: VS Code + Cursor (always installed)
>          Toggles: node=true python-dev=false jq=false flutter=false
>        Asks: "Shall I run this now?"
>        User: "yes".
>        Agent: executes the script, streams output, reports the external IP.
>        Opens `references/post-install-runbook.md` and walks through it.
