# Camunda Infrastructure Experience Interview: Coding Challenge

Please refer to the documentation about the challenge: [document](https://docs.google.com/document/d/1Y2urs8QjpTjGHdmul-bO5kg4K_wtj-vBsn5Ipf4g9SI/edit)

## `Makefile`

The main entrypoint to invoke different commands from the test framework:

- **make apply**: Apply both Terraform workspaces, one after another
- **make apply-cluster**: Apply the 01-cluster-create Terraform workspace
- **make apply-deploy**: Apply the 02-app-deploy Terraform workspace
- **make check-todos**: Check all TODOs were addressed
- **make check-tools**: Check all required tools are installed
- **make destroy**: Destroy both Terraform workspaces, one after another
- **make full-test**: Run the full testing suite
- **make help**: Display this help
- **make localstack-start**: Start Localstack locally with all the correct configurations
- **make localstack-stop**: Stop Localstack
- **make test**: Check that the S3 app works correctly and the Terraform outputs are correct

You don't need to change this file.

## `Feedback.md`

A document for the you to leave Camunda feedback.

## `01-cluster-create`

The Terraform workspace to create a kind k8s cluster and an S3 bucket in Localstack.

Relies on the module in `modules/infrastucture`.

You don't need to edit it.

## `02-app-deploy`

The Terraform workspace to deploy an nginx controller and an S3 app into the kind cluster.

Relies on the module in `modules/deploy`.

You don't need to edit it.

## `modules/infrastructure`

The Terraform module to create a kind k8s cluster and an S3 bucket in Localstack.

You need to implement this module.

## `modules/deploy`

The Terraform module to deploy an nginx controller and an S3 app into the kind cluster.

You need to implement this module.

## `scripts`

Auxiliary scripts used by the aforementioned `make` targets.

You don't need to edit these files.

You don't need to run them directly (use the aforementioned `make` targets).
