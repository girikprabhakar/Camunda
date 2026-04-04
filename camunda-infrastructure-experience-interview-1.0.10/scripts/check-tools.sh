#!/bin/bash

# WARNING: You don't need to edit this file!

# This script checks that the following tools are installed:
# - Docker
# - kind
# - kubectl
# - localstack

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# shellcheck source=/dev/null
. "${SCRIPTPATH}/_library.sh"

set -eu

SUCCESS="true"

function mark_fail() {
  SUCCESS="false"
}

function check_command() {
  CMD="$1"
  PRG=$(echo "$CMD" | cut -d " " -f1)
  log_test "Checking that $PRG is installed"
  if ! $CMD &> /dev/null
  then
    log_fail "$PRG not installed or not running"
    return 1
  else
    log_pass "$PRG is installed"
  fi
}

if check_command docker; then
  log_info "$(docker --version)"
else
  mark_fail
fi
docker_running=$(docker info >/dev/null 2>&1 && echo "true" || echo "false")
if [[ $docker_running == "true" ]]; then
  log_info "Docker daemon is runnning"
else
  log_fail "Docker daemon is not running"
  mark_fail
fi

if check_command kubectl; then
  log_info "$(kubectl version --client=true)"
else
  mark_fail
fi
if check_command kind; then
  log_info "$(kind --version)"
else
  mark_fail
fi
if check_command "curl -V"; then
  log_info "$(curl --version)"
else
  mark_fail
fi
if check_command "jq --version"; then
  log_info "$(jq --version)"
else
  mark_fail
fi

log_test "Checking that Localstack Docker container is running"
CONTAINER_NAME="camunda_localstack"
CONTAINER_ID=$(docker ps -aqf "name=$CONTAINER_NAME")
if [[ "$(docker inspect -f \{\{.State.Health.Status\}\} "$CONTAINER_ID")" == "healthy" ]] ; then
  log_pass "Localstack Docker container is running"
else
  log_fail "Localstack Docker container is not running. Did you run 'make localstack-start'?"
  mark_fail
fi

if [[ "$SUCCESS" != "true" ]]; then
  exit 1
else
  exit 0
fi
