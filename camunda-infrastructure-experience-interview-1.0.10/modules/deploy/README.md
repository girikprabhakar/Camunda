# Deploy Module

## Overview

The `deploy` module installs the nginx ingress and S3 app into an already existing Kubernetes cluster.

Steps:

- creating a namespace for the ingress-nginx controller
- deploying ingress-nginx through the Helm provider
- creating a namespace for the S3 app
- deploying the S3 app as a Kubernetes Deployment
- exposing the S3 app internally through a ClusterIP Service
- publishing the app externally through a Kubernetes Ingress on `localhost:8086/s3-app`

This module does not create the cluster itself. The cluster and kubeconfig context must already exist before this module is applied.

## Background

 `02-app-deploy` assumes that:

- the kind cluster has already been created
- the Kubernetes context `kind-<cluster-name>` is available in `~/.kube/config`
- the infrastructure layer has already created the required Localstack S3 bucket and uploaded the expected object

## Usage
The module is used by the `02-app-deploy` to make the S3 app reachable at:

```
http://localhost:8086/s3-app
```

## Flow

The module applies resources in the following order:

1. Create the namespace for ingress-nginx.
2. Render Helm values from `nginx-helm-chart-values-template.yaml`.
3. Install the ingress-nginx Helm chart into the ingress namespace.
4. Create the namespace for the S3 app.
5. Deploy the S3 app container with the provided image, labels, replica count, and environment variables.
6. Create a ClusterIP Service targeting the S3 app Pods.
7. Create an Ingress that routes `/s3-app` traffic to the Service using the configured ingress class.

## Module Inputs

### `nginx_ingress`

Configuration for the ingress-nginx controller Helm release.

Attributes:

- `namespace`: Namespace where ingress-nginx will be installed.
- `replicas`: Number of ingress-nginx controller replicas.
- `ingress_class_name`: Name of the ingress class exposed by the controller.
- `chart_repository`: Helm repository URL containing the ingress-nginx chart.
- `chart_name`: Helm chart name to install.
- `chart_version`: Version of the Helm chart to install.

### `s3_app`

Configuration for the S3 application and its ingress exposure.

Attributes:

- `namespace`: Namespace where the S3 app will be deployed.
- `image`: Container image for the S3 app.
- `replicas`: Number of application replicas.
- `ingress_class_name`: Ingress class name that must match the ingress-nginx controller configuration.
- `ingress_path`: HTTP path exposed through the Ingress.
- `labels`: Labels applied to the Deployment, Service, and Ingress resources.
- `env_vars`: List of environment variables passed to the application container.
  -  Each item in `env_vars` contains:
       - `name`: Environment variable name.
       - `value`: Environment variable value.

## Output
The module exports:
- `nginx_ingress_app_version`: the deployed ingress-nginx controller application version retrieved from by the Helm release metadata

## Resources Created

### Namespaces

The module creates 2 namespaces:

- ingress namespace for ingress-nginx
- application namespace for the S3 app


### Helm Release for Nginx Ingress Controller

The ingress controller is installed through a `helm_release` resource from the `helm` provider.

The chart values are rendered from `nginx-helm-chart-values-template.yaml` using `templatefile` function. The template configures:

- a custom ingress class resource name
- a configurable controller replica count
- disables admission webhooks
- `hostNetwork: true`
- `NodePort` service type

### Deployment

The S3 app is deployed as a Kubernetes Deployment using the `kubernetes_deployment_v1` resource from the `kubernetes` provider.

Implementation:

- the application name is derived from `labels.app` and defaults to `s3-app` if not provided.
- the container image comes from `var.s3_app.image`
- the replica count comes from `var.s3_app.replicas`
- pod labels are reused as selector labels
- all environment variables from `var.s3_app.env_vars` are injected into the container
- the container port is derived from the `PORT` environment variable

### Service

The application is exposed internally through a ClusterIP Service.

- selects Pods using `var.s3_app.labels`
- exposes the same port derived from the `PORT` environment variable

### Application Ingress

The application is published through a Kubernetes Ingress resource using the `kubernetes_ingress_v1` resource from the `kubernetes` provider.

Implementation:

- the ingress class name is set from `var.s3_app.ingress_class_name`
- the HTTP path is taken from `var.s3_app.ingress_path`
- the path type is `Prefix`
- the Ingress backend points to the S3 app Service



## Dependency Flow

- the Helm release depends on the ingress namespace
- the application Deployment and Service depend on the application namespace
- the Ingress depends on the ingress controller, application Deployment, and Service

## Providers

This module does not declare or configure provider blocks. It expects the caller to supply:

- a configured `kubernetes` provider
- a configured `helm` provider

## Assumptions

- The kind cluster already exists and is reachable.
- The ingress-nginx chart repository is reachable from the machine running Terraform.
- The application image is already built and available in the configured container registry.
- Localstack is already running

## Testing Instructions

- `cd` into the `02-app-deploy` workspace and run `terraform init` to initialize the workspace and download the required providers.
- Run `terraform apply` to apply the module and deploy the application.

Result:

- ingress-nginx should be installed in the configured namespace
- the S3 app Pod should be running in its namespace
- the Ingress should route traffic for `/s3-app`
- a request to `http://localhost:8086/s3-app` should return a JSON payload like:
  ```JSON
    {
        "status": "OK",
        "s3_endpoint": "http://host.docker.internal:4566",
        "bucket_found_status": true,
        "file_found_status": true,
        "file_content_correct_status": true,
        "file_path": "s3://test-bucket/test-file",
        "file_content_checksum": "df5210863d3dea0dcac4a3232bd833b3",
        "file_content_checksum_control": "df5210863d3dea0dcac4a3232bd833b3"
    }
  ```

## Module Layout

The deploy module is split across the following files:

- `variables.tf`: input contract for the module
- `nginx.tf`: ingress namespace creation and Helm release
- `s3_app.tf`: application namespace, Deployment, Service, and Ingress
- `outputs.tf`: exported module outputs
- `nginx-helm-chart-values-template.yaml`: rendered Helm values for ingress-nginx

```
.
├── nginx-helm-chart-values-template.yaml
├── nginx.tf
├── outputs.tf
├── README.md
├── s3_app.tf
└── variables.tf

1 directory, 6 files
```
