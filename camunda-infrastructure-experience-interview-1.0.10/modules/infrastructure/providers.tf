# use this file configure the module to use the latest version of provider tehcyx/kind.
# The provider readme: https://registry.terraform.io/providers/tehcyx/kind/latest/docs/resources/cluster
terraform {
    required_version = ">= 1.9.0"
    required_providers {
        kind = {
        source  = "tehcyx/kind"
        version = "0.11.0"
        }
    }
}