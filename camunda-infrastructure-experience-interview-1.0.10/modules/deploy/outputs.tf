# create the required output(s) of the module here
output "nginx_ingress_app_version" {
    description = "App version of the deployed ingress-nginx controller."
    value       = helm_release.nginx_ingress.metadata.app_version
}