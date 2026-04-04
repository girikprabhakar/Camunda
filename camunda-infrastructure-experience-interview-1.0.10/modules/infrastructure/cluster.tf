# TODO: create code to create a kind cluster using Terraform,
# with the following equivalent configuration:
# (see providers.tf for the provider information and settings)

# Important: make sure nothing runs on your port 8086 locally
# (otherwise the kind cluster's port binding won't work)

# ---
# kind: Cluster
# apiVersion: kind.x-k8s.io/v1alpha4
# name: <cluster-name>
# nodes:
# - role: control-plane
#   image: kindest/node:v<k8s-version>
# - role: worker
#   image: kindest/node:v<k8s-version>
#   extraPortMappings:
#   - containerPort: 80
#     hostPort: 8086
#     listenAddress: "0.0.0.0"
