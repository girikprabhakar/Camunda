# please add the required module variables here
variable nginx_ingress {
    description = "Configuration for the NGINX Ingress Controller deployment"
    type = object({
        namespace          = string
        replicas           = number
        ingress_class_name = string
        chart_repository   = string
        chart_name         = string
        chart_version      = string
    })
}
variable s3_app {
    description = "Configuration for the S3 app deployment"
    type = object({
        namespace          = string
        image              = string
        replicas           = number
        ingress_class_name = string
        ingress_path       = string
        labels             = map(string)
        env_vars           = list(object({
            name  = string
            value = string
        }))
    })
}