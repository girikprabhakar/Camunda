#!/bin/bash

# WARNING: You don't need to edit this file!

# Checks that the S3 app is available and has the right status
# Checks that Terraform workspaces have the expected outputs

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# shellcheck source=/dev/null
. "${SCRIPTPATH}/_library.sh"

set -e

# Checking the S3 app

log_test "Check the S3 app is running in the cluster and is working as expected"
URL=http://localhost:8086/s3-app

log_info "Running: curl -L --fail $URL"
curl -L --fail $URL

data=$(curl $URL)
status=$(echo "$data" | jq -r '.status')

echo "Output:"
echo "$data" | jq .

if [ "$status" != "OK" ]; then
  log_fail "ERROR: The S3 app is not working as expected"
  exit 1
else
  log_pass "OK: The S3 app is working as expected"
fi

# Checking the outputs of the Terraform workspaces

output_name="cluster_endpoint"
workspace="01-cluster-create"
log_test "Check the Terraform $workspace has a correct output: $output_name"
cd "${SCRIPTPATH}/../${workspace}"
output_value=$(terraform output -raw ${output_name})
log_info "Trying to connect to $output_name: curl $output_value --silent -k"
data=$(curl "$output_value" --silent -k | jq -r '.message')
# we expect a response from a k8s api server to disallow unauthorized access:
expected_data='forbidden: User "system:anonymous" cannot get path "/"'
log_info "$output_name=$output_value"
if [[ "${data}" == "${expected_data}" ]]; then
  log_pass "Check for $output_name passed"
else
  log_fail "Check for $output_name did not pass"
  log_info "Response from the endpoint:\n$data"
  log_info "Expected response:\n$expected_data"
fi

output_name="nginx_ingress_app_version"
workspace="02-app-deploy"
log_test "Check the Terraform $workspace has a correct output: $output_name"
cd "${SCRIPTPATH}/../${workspace}"
output_value=$(terraform output -raw ${output_name})
# we expect a specific nginx version from the Helm chart we used:
expected_value='1.12.3'
log_info "$output_name=$output_value"
if [[ "${output_value}" == "${expected_value}" ]]; then
  log_pass "Check for $output_name passed"
else
  log_fail "Check for $output_name did not pass"
  log_info "Got: $output_value"
  log_info "Expected: $expected_value"
fi
