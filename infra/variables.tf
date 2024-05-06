variable cluster_name {
  description = "The EKS project to deploy resources to"
  type = string
  default = "testing-cloud"
}

variable instance_type {
  description = "The instance type to use for the EKS cluster"
  type = string
  default = "t3.medium"
}