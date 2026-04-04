#!/bin/bash

# WARNING: You don't need to edit this file!

# Creates the resources in the workspaces

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# shellcheck source=/dev/null
. "${SCRIPTPATH}/_library.sh"

set -e

function apply_workspace() {
  workspace="$1"
  log_test "Applying workspace ${workspace}"
  cd "${SCRIPTPATH}/../${workspace}"
  log_info "Applying workspace ${workspace}"
  terraform init -upgrade
  if terraform apply -auto-approve; then
    log_pass "Workspace ${workspace} applied successfully"
  else
    log_fail "Workspace ${workspace} could not be applied"
  fi
}

workspace="$1"

if [ -z "$workspace" ]; then
  apply_workspace "01-cluster-create"
  apply_workspace "02-app-deploy"
else
  apply_workspace "$workspace"
fi
