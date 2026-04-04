#!/bin/bash

# WARNING: You don't need to edit this file!

# Deletes the resources in the workspaces

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# shellcheck source=/dev/null
. "${SCRIPTPATH}/_library.sh"

set -e

function destroy() {
  workspace="$1"
  log_test "Destroying workspace ${workspace}"
  cd "${SCRIPTPATH}/../${workspace}"
  log_info "Destroying workspace ${workspace}"
  if terraform destroy -auto-approve; then
    log_pass "Workspace ${workspace} destroyed successfully"
  else
    log_fail "Workspace ${workspace} could not be destroyed"
  fi
  rm -f test-cluster-config
}

DELETE=$(yes_no "Do you want to delete all the Terraform resources (kind cluster and the resources in it)?")

if [[ "$DELETE" == "y" ]]; then
  destroy "02-app-deploy"
  destroy "01-cluster-create"
else
  log_info "Skipping workspaces deletion"
fi
