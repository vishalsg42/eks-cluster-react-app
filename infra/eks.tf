module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  cluster_name                             = var.cluster_name
  cluster_endpoint_public_access           = true
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true
  create_iam_role                          = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  iam_role_additional_policies = {
    policy = aws_iam_policy.elb_policy.arn
  }
  cluster_addons = {
    # coredns = {
    #   resolve_conflicts = "OVERWRITE"
    # }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    disk_size                  = 20
    instance_types             = ["t3.medium"]
    ami_type                   = "AL2_x86_64"
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    Infrastructure = {
      subnet_ids   = module.vpc.private_subnets
      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}

data "aws_iam_policy_document" "elb_policy" {
  statement {
    actions   = ["elasticloadbalancing:CreateLoadBalancer"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "elb_policy" {
  name        = "elb-policy"
  description = "Policy to allow creating Elastic Load Balancers"
  policy      = data.aws_iam_policy_document.elb_policy.json
}


module "vpc_cni_irsa" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true # NOTE: This was what needed to be added

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  # Use the AWS provider to get the token for EKS authentication
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}

resource "kubernetes_deployment" "react_app" {
  metadata {
    name = "react-app"
    labels = {
      app = "react-app"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "react-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "react-app"
        }
      }

      spec {
        container {
          name  = "react-app"
          image = "673271929208.dkr.ecr.eu-west-2.amazonaws.com/react-app:latest" # Replace with your actual ECR image URL
          resources {
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "500Mi"
            }
          }
          port {
            container_port = 3000 # Assuming React app serves on port 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "react_service" {
  metadata {
    name = "react-service"
  }

  spec {
    selector = {
      app = "react-app"
    }

    port {
      port        = 80
      target_port = 3000
    }

    type = "NodePort" # Change service type to NodePort
  }
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}



# resource "kubernetes_service" "react_app_service" {
#   metadata {
#     name = "react-app-service"
#   }

#   spec {
#     selector = {
#       app = "react-app"
#     }

#     port {
#       protocol    = "TCP"
#       port        = 80
#       target_port = 3000
#     }

#     type = "LoadBalancer"
#   }
# }
