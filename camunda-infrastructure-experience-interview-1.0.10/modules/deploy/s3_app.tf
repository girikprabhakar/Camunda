# deploy the dummy S3 app in the kind cluster in a given namespace.
# Check 02-app-deploy/main.tf for all the details of the app.

# The app should be accessible from localhost via an Ingress on localhost:8086/s3-app
# The app is stateless. No TLS is required (plain HTTP)

# Hint: pay attention to ingressClassName value of the Ingress object for the solution to work
locals {
    s3_app_name = lookup(var.s3_app.labels, "app", "s3-app")
    s3_app_port = tonumber(one([
        for env_var in var.s3_app.env_vars : env_var.value
        if env_var.name == "PORT"
    ]))
}

resource "kubernetes_namespace_v1" "s3_app" {
    metadata {
        name = var.s3_app.namespace
    }
}

resource "kubernetes_deployment_v1" "s3_app" {
    wait_for_rollout = true
    metadata {
        name      = local.s3_app_name
        namespace = kubernetes_namespace_v1.s3_app.metadata[0].name
        labels    = var.s3_app.labels
    }

    spec {
        replicas = var.s3_app.replicas

        selector {
            match_labels = var.s3_app.labels
        }

        template {
            metadata {
                labels = var.s3_app.labels
            }
            spec {
                container {
                    name  = local.s3_app_name
                    image = var.s3_app.image
                    port {
                        container_port = local.s3_app_port
                    }
                    dynamic "env" {
                        for_each = var.s3_app.env_vars
                        content {
                            name  = env.value.name
                            value = env.value.value
                        }
                    }
                }
            }
        }
    }
    depends_on = [ kubernetes_namespace_v1.s3_app ]
}

resource "kubernetes_service_v1" "s3_app" {
    metadata {
        name      = local.s3_app_name
        namespace = kubernetes_namespace_v1.s3_app.metadata[0].name
        labels    = var.s3_app.labels
    }
    spec {
        selector = var.s3_app.labels
        port {
            port        = local.s3_app_port
            target_port = local.s3_app_port
        }
        type = "ClusterIP"
    }
    depends_on = [
        kubernetes_namespace_v1.s3_app,
        kubernetes_deployment_v1.s3_app
    ]
}

resource "kubernetes_ingress_v1" "s3_app" {
    metadata {
        name      = "${local.s3_app_name}-ingress"
        namespace = kubernetes_namespace_v1.s3_app.metadata[0].name
        labels    = var.s3_app.labels
    }

    spec {
        ingress_class_name = var.s3_app.ingress_class_name
        rule {
            http {
                path {
                    path      = var.s3_app.ingress_path
                    path_type = "Prefix"
                    backend {
                        service {
                            name = kubernetes_service_v1.s3_app.metadata[0].name
                            port {
                                number = local.s3_app_port
                            }
                        }
                    }
                }
            }
        }
    }

    depends_on = [
            helm_release.nginx_ingress,
            kubernetes_service_v1.s3_app,
            kubernetes_deployment_v1.s3_app
        ]
}

# This resource is added to have a delay before accessing the http://localhost:8086/s3-app
resource "null_resource" "sleep_10s" {
    triggers = {
        always_run = timestamp()
    }

    provisioner "local-exec" {
        command = "sleep 10"
    }

    depends_on = [
        kubernetes_ingress_v1.s3_app
    ]
}