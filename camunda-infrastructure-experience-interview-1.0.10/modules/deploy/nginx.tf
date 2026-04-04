# deploy nginx ingress controller in a given namespace of the kind cluster
# Deployment needs to the done using the ingress-nginx helm chart (see
# 02-app-deploy/main.tf for details)
# Use nginx-helm-chart-values-template.yml to generate the values for the helm chart
# (hint: use the Terraform's templatefile function)

locals {
    nginx_ingress_values = templatefile(
        "${path.module}/nginx-helm-chart-values-template.yaml",
        {
            ingressClassName = var.nginx_ingress.ingress_class_name
            replicas         = var.nginx_ingress.replicas
        }
    )
}

resource "kubernetes_namespace_v1" "nginx_ingress" {
    metadata {
        name = var.nginx_ingress.namespace
    }
}


resource "helm_release" "nginx_ingress" {
    name       = var.nginx_ingress.chart_name
    repository = var.nginx_ingress.chart_repository
    chart      = var.nginx_ingress.chart_name
    version    = var.nginx_ingress.chart_version
    namespace  = kubernetes_namespace_v1.nginx_ingress.metadata[0].name

    values = [local.nginx_ingress_values]
    depends_on = [kubernetes_namespace_v1.nginx_ingress]
}