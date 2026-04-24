#!/usr/bin/env bash
# =============================================================================
# create-dev-machine.sh — provision a GCP Compute dev VM from a startup script
# -----------------------------------------------------------------------------
# Invoked by the `gcp-dev-machine-builder` skill (or a human). All parameters
# are passed as flags — no environment files, no hard-coded values.
#
# The script:
#   1. Pre-flight checks (gcloud installed, authenticated, project exists,
#      machine name free, startup template present).
#   2. Renders the final startup.sh from the template by substituting the
#      INSTALL_* toggle placeholders.
#   3. Reserves a regional static IP (STANDARD tier).
#   4. Creates the Compute instance (Spot, Ubuntu 24.04 LTS by default).
#   5. Prints the next-step instructions.
# =============================================================================

set -euo pipefail

# ---- Defaults ---------------------------------------------------------------
REGION_DEFAULT="asia-southeast1"
ZONE_DEFAULT="asia-southeast1-a"
MACHINE_TYPE_DEFAULT="n1-standard-2"
DISK_SIZE_DEFAULT="200GB"
UBUNTU_IMAGE_FAMILY_DEFAULT="ubuntu-2404-lts-amd64"
IMAGE_PROJECT_DEFAULT="ubuntu-os-cloud"

# ---- Flag variables (no defaults where a value is required) -----------------
PROJECT=""
MACHINE_NAME=""
REGION="$REGION_DEFAULT"
ZONE="$ZONE_DEFAULT"
MACHINE_TYPE="$MACHINE_TYPE_DEFAULT"
DISK_SIZE="$DISK_SIZE_DEFAULT"
IMAGE_FAMILY="$UBUNTU_IMAGE_FAMILY_DEFAULT"
IMAGE_PROJECT="$IMAGE_PROJECT_DEFAULT"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STARTUP_TEMPLATE="${SCRIPT_DIR}/startup.sh"
PROVISIONING_MODEL="SPOT"     # pass --on-demand to switch to standard

# Toggle defaults (all off — the agent should pass explicit values).
# NOTE: VS Code and Cursor are baseline in startup.sh; no flags for them.
INSTALL_NODE_STACK="false"
INSTALL_PYTHON_DEV="false"
INSTALL_JQ="false"
INSTALL_FLUTTER="false"

DRY_RUN="false"

# =============================================================================
# Usage
# =============================================================================
usage() {
  cat <<USAGE
Usage: $(basename "$0") --project PROJECT --name NAME [options]

Required:
  --project PROJECT         GCP project ID.
  --name    NAME            VM instance name (also used for the static IP).

Location (defaults: ${REGION_DEFAULT} / ${ZONE_DEFAULT}):
  --region  REGION
  --zone    ZONE

Machine (defaults: ${MACHINE_TYPE_DEFAULT}, ${DISK_SIZE_DEFAULT}):
  --machine-type TYPE
  --disk-size    SIZE       e.g. 200GB

Image (defaults: ${UBUNTU_IMAGE_FAMILY_DEFAULT} / ${IMAGE_PROJECT_DEFAULT}):
  --image-family FAMILY
  --image-project PROJECT

Provisioning:
  --on-demand               Use standard on-demand billing (default: SPOT).

Dev toolchain toggles (true/false, default false):
  --with-node [true|false]
  --with-python-dev [true|false]
  --with-jq [true|false]
  --with-flutter [true|false]

  (VS Code and Cursor are baseline — always installed, no flags.)

Other:
  --startup-template PATH   Override the startup template file.
  --dry-run                 Render and pre-flight only; do NOT create resources.
  -h | --help               Show this help.
USAGE
}

# =============================================================================
# Parse flags
# =============================================================================
require_value() {
  # Ensure a flag that takes a value actually received one (not another flag).
  local flag="$1" value="${2-}"
  if [[ -z "$value" || "$value" == --* ]]; then
    echo "ERROR: flag '$flag' requires a value" >&2; exit 2
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)          require_value "$1" "${2-}"; PROJECT="$2"; shift 2 ;;
    --name)             require_value "$1" "${2-}"; MACHINE_NAME="$2"; shift 2 ;;
    --region)           require_value "$1" "${2-}"; REGION="$2"; shift 2 ;;
    --zone)             require_value "$1" "${2-}"; ZONE="$2"; shift 2 ;;
    --machine-type)     require_value "$1" "${2-}"; MACHINE_TYPE="$2"; shift 2 ;;
    --disk-size)        require_value "$1" "${2-}"; DISK_SIZE="$2"; shift 2 ;;
    --image-family)     require_value "$1" "${2-}"; IMAGE_FAMILY="$2"; shift 2 ;;
    --image-project)    require_value "$1" "${2-}"; IMAGE_PROJECT="$2"; shift 2 ;;
    --on-demand)        PROVISIONING_MODEL="STANDARD"; shift ;;
    --with-node)        require_value "$1" "${2-}"; INSTALL_NODE_STACK="$2"; shift 2 ;;
    --with-python-dev)  require_value "$1" "${2-}"; INSTALL_PYTHON_DEV="$2"; shift 2 ;;
    --with-jq)          require_value "$1" "${2-}"; INSTALL_JQ="$2"; shift 2 ;;
    --with-flutter)     require_value "$1" "${2-}"; INSTALL_FLUTTER="$2"; shift 2 ;;
    --startup-template) require_value "$1" "${2-}"; STARTUP_TEMPLATE="$2"; shift 2 ;;
    --dry-run)          DRY_RUN="true"; shift ;;
    -h|--help)          usage; exit 0 ;;
    *)                  echo "ERROR: unknown flag: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# =============================================================================
# Pre-flight
# =============================================================================
log()  { printf '[%s] %s\n' "$(date -u +%H:%M:%SZ)" "$*"; }
fail() { echo "ERROR: $*" >&2; exit 1; }

# Required flags
[[ -n "$PROJECT"      ]] || { usage >&2; fail "--project is required"; }
[[ -n "$MACHINE_NAME" ]] || { usage >&2; fail "--name is required"; }

# GCP naming: lowercase letters, digits, hyphens; start with a letter; <=63 chars.
if [[ ! "$MACHINE_NAME" =~ ^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$ ]]; then
  fail "--name '$MACHINE_NAME' is not a valid GCE instance name"
fi

# Toggle values must be true/false
for var in INSTALL_NODE_STACK INSTALL_PYTHON_DEV INSTALL_JQ INSTALL_FLUTTER; do
  val="${!var}"
  [[ "$val" == "true" || "$val" == "false" ]] \
    || fail "$var must be 'true' or 'false' (got '$val')"
done

# gcloud present?
command -v gcloud >/dev/null \
  || fail "gcloud CLI not found on PATH. Install it: https://cloud.google.com/sdk/docs/install"

# gcloud authenticated?
ACTIVE_ACCOUNT="$(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null || true)"
[[ -n "$ACTIVE_ACCOUNT" ]] \
  || fail "No active gcloud account. Run: gcloud auth login"
log "Using gcloud account: $ACTIVE_ACCOUNT"

# Project accessible?
gcloud projects describe "$PROJECT" >/dev/null 2>&1 \
  || fail "Cannot access project '$PROJECT' (check spelling and IAM)"
log "Project '$PROJECT' is accessible"

# Startup template present?
[[ -f "$STARTUP_TEMPLATE" ]] \
  || fail "Startup template not found: $STARTUP_TEMPLATE"

# Instance name collision?
if gcloud compute instances describe "$MACHINE_NAME" \
     --project="$PROJECT" --zone="$ZONE" >/dev/null 2>&1; then
  fail "Instance '$MACHINE_NAME' already exists in zone '$ZONE'"
fi

# IP name collision?
IP_NAME="${MACHINE_NAME}-ip"
if gcloud compute addresses describe "$IP_NAME" \
     --project="$PROJECT" --region="$REGION" >/dev/null 2>&1; then
  fail "Address '$IP_NAME' already exists in region '$REGION'"
fi

# =============================================================================
# Render startup.sh (substitute INSTALL_* toggles)
# =============================================================================
RENDERED_STARTUP="$(mktemp -t startup.XXXXXX.sh)"
trap 'rm -f "$RENDERED_STARTUP"' EXIT

sed \
  -e "s|__INSTALL_NODE_STACK__|${INSTALL_NODE_STACK}|g" \
  -e "s|__INSTALL_PYTHON_DEV__|${INSTALL_PYTHON_DEV}|g" \
  -e "s|__INSTALL_JQ__|${INSTALL_JQ}|g" \
  -e "s|__INSTALL_FLUTTER__|${INSTALL_FLUTTER}|g" \
  "$STARTUP_TEMPLATE" > "$RENDERED_STARTUP"

# Sanity-check: no placeholders left.
if grep -q '__INSTALL_[A-Z_]*__' "$RENDERED_STARTUP"; then
  fail "Unresolved toggle placeholder(s) in rendered startup script"
fi

log "Rendered startup script: $RENDERED_STARTUP"
log "Toggles — node=$INSTALL_NODE_STACK python-dev=$INSTALL_PYTHON_DEV jq=$INSTALL_JQ flutter=$INSTALL_FLUTTER (vscode+cursor baseline)"

if [[ "$DRY_RUN" == "true" ]]; then
  log "DRY RUN: pre-flight passed. Not creating any resources."
  log "Rendered startup script kept at: $RENDERED_STARTUP"
  trap - EXIT
  exit 0
fi

# =============================================================================
# Create resources
# =============================================================================
log "Setting active project to '$PROJECT'"
gcloud config set project "$PROJECT" >/dev/null

log "Reserving static external IP '$IP_NAME' in region '$REGION'"
gcloud compute addresses create "$IP_NAME" \
  --project="$PROJECT" \
  --network-tier=STANDARD \
  --region="$REGION"

IP_ADDRESS="$(gcloud compute addresses describe "$IP_NAME" \
  --project="$PROJECT" --region="$REGION" --format='value(address)')"
[[ -n "$IP_ADDRESS" ]] || fail "Failed to read reserved IP address"
log "Reserved IP: $IP_ADDRESS"

log "Creating Compute instance '$MACHINE_NAME' in zone '$ZONE' (${PROVISIONING_MODEL})"
gcloud compute instances create "$MACHINE_NAME" \
  --project="$PROJECT" \
  --zone="$ZONE" \
  --machine-type="$MACHINE_TYPE" \
  --provisioning-model="$PROVISIONING_MODEL" \
  --image-family="$IMAGE_FAMILY" \
  --image-project="$IMAGE_PROJECT" \
  --boot-disk-size="$DISK_SIZE" \
  --boot-disk-type=pd-standard \
  --boot-disk-device-name="$MACHINE_NAME" \
  --metadata-from-file="startup-script=$RENDERED_STARTUP" \
  --network-tier=STANDARD \
  --address="$IP_ADDRESS" \
  --subnet=default \
  --tags=http-server,https-server

log "Instance created. External IP: $IP_ADDRESS"

# =============================================================================
# Next-step instructions
# =============================================================================
cat <<NEXT

-----------------------------------------------------------------------
Dev machine '$MACHINE_NAME' is provisioning.
The startup script is running now — it typically takes 5–15 minutes.

Watch its progress (in another terminal):
  gcloud compute ssh $MACHINE_NAME --project=$PROJECT --zone=$ZONE \\
    --command='sudo journalctl -u google-startup-scripts.service -f'

It is done when you see the marker line:
  STARTUP_SCRIPT_DONE

Then follow the post-install runbook to finish the setup:
  .agents/skills/gcp-dev-machine-builder/references/post-install-runbook.md
  (Chrome Remote Desktop PIN, SSH key, disable autoscreen lock, .bashrc tweaks)
-----------------------------------------------------------------------
NEXT
