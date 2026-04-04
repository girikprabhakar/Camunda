# create the required output(s) of the module here
output "cluster_endpoint" {
    value = kind_cluster.default.endpoint
}