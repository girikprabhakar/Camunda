# Infrastructure Module

## Overview

The `infrastructure` module is responsible for:

- creating a local kind Kubernetes cluster
- creating an S3 bucket through the AWS provider configured for Localstack
- uploading a configuration file into that S3 bucket
- exposing the Kubernetes cluster endpoint as a Terraform output


## Usage

This module is used by the `01-cluster-create` workspace.

The calling workspace provides the following values:

- cluster name
- Kubernetes version
- bucket name
- object key
- source filename for the uploaded object

The workspace then exports the module output `cluster_endpoint`

## Flow

The module applies the following resources:

1. Create a kind cluster with one control-plane node and one worker node.
2. Create an S3 bucket in Localstack.
3. Upload the provided configuration file into the bucket under the requested object key.
4. Export the cluster endpoint as output of the module.

### 1. kind Cluster

The module creates a kind cluster using the `kind_cluster` resource from the `tehcyx/kind` provider.

The current cluster topology is:

- 1 control-plane node
- 1 worker node
- both nodes use the image `kindest/node:v<cluster_version>`

The worker node also exposes an extra port mapping:

- container port `80`
- host port `8086`
- listen address `0.0.0.0`


### 2. S3 Bucket In Localstack

The module creates an `aws_s3_bucket` resource using the bucket name provided as input.

### 3. Object Upload

The module uploads a file to the created bucket using `aws_s3_object`.

The uploaded object uses:

- `bucket = aws_s3_bucket.my_bucket.id`
- `key = var.object_name`
- `source = "${path.root}/${var.config_filename}"`

Uses `path.root` because the source file is expected to exist in the calling workspace directory, not inside the module directory itself.


## Module Inputs

The module uses five input variables.

### `cluster_name`
  - The name of the kind cluster to create.

### `cluster_version`
  - The Kubernetes version used to construct the kind node image:

    ```
    kindest/node:v<cluster_version>
    ```
    Example:
    ```
    1.33.0
    ```
    which becomes:
    ```
    kindest/node:v1.33.0
    ```

### `bucket_name`
  - The name of the bucket to create in Localstack S3.

### `object_name`
  - The key under which the configuration file will be uploaded to the bucket.

### `config_filename`
  - The relative filename, from the root Terraform workspace, of the file that should be uploaded into the bucket.

## Output
The module exports one output.

- `cluster_endpoint` This output exposes the Kubernetes API server endpoint returned by the `kind_cluster` resource.
## Providers

This module works with two providers, but they are sourced from different places.

### kind Provider

The module declares the `tehcyx/kind` provider in `providers.tf` with:

- source: `tehcyx/kind`
- version: `0.11.0`

This provider is used only for cluster creation.

### AWS Provider

The module also uses AWS resources. `01-cluster-create/providers.tf` configures the AWS provider to talk to Localstack

- `aws_s3_bucket`
- `aws_s3_object`



## Testing Instructions

- `cd` into the `01-cluster-create` workspace and run `terraform init` to initialize the workspace and download the required providers.
- Run `terraform apply` to apply the module and create the cluster and S3 resources.

Result:
- the kind cluster should exist locally
- the Kubernetes API endpoint should be available through the `cluster_endpoint` output
- the Localstack bucket should exist
- the uploaded object should exist at the expected key

## Cluster Details

kind configuration:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: <cluster-name>
nodes:
  - role: control-plane
    image: kindest/node:v<k8s-version>
  - role: worker
    image: kindest/node:v<k8s-version>
    extraPortMappings:
      - containerPort: 80
        hostPort: 8086
        listenAddress: "0.0.0.0"
```

## File Upload
- the bucket must exist before the upload runs
- the source file must exist in the root workspace directory
- the object content is taken directly from the source file and not generated in the module

## Assumptions

This module assumes:

- Docker is installed and running
- Localstack is already running and reachable on `127.0.0.1:4566`
- kind can create containers locally
- host port `8086` is free before cluster creation
- the AWS provider has been configured by the caller to talk to Localstack
- the file referenced by `config_filename` exists in the root workspace


## Module Layout

The current implementation is split across the module files as follows:

- `providers.tf`: declares the `tehcyx/kind` provider requirement
- `variables.tf`: declares module inputs
- `cluster.tf`: creates the local kind cluster
- `s3.tf`: creates the bucket and uploads the object
- `outputs.tf`: exports the cluster endpoint
```
.
├── cluster.tf
├── outputs.tf
├── providers.tf
├── README.md
├── s3.tf
└── variables.tf
```
## Notes

### Port Binding

Port `8086` on the host must be available.

If another process is already using that port, the worker node port mapping will fail and the cluster may not be created properly.

### Localstack Dependency

The S3 resources are created against Localstack, not AWS.

If Localstack is not running, bucket creation and file upload will fail even if the kind cluster is created successfully.