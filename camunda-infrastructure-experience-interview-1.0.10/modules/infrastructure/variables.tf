# please add the required module variables here
variable "cluster_name" {
    type = string
    description = "Name of the cluster to be created"
}

variable "cluster_version" {
    type = string
    description = "Kubernetes version of the cluster"
}

variable "bucket_name" {
    type = string
    description = "Name of the S3 bucket to be created"
}

variable "object_name" {
    type = string
    description = "Name/Key of the object to be created in the S3 bucket"
}

variable "config_filename" {
    type = string
    description = "Name of the file containing the object contents"
}
