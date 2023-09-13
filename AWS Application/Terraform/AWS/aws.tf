/* Useful documentation: 
https://medium.com/aws-infrastructure/setup-kubernetes-cluster-with-aws-eks-and-terraform-c46d5e916ad9 
https://aws-ia.github.io/terraform-aws-eks-blueprints/v4.32.1/core-concepts/
https://antonputra.com/amazon/create-eks-cluster-using-terraform-modules/#deploy-aws-load-balancer-controller
*/

##################################################  Create Postgres (3m 37s) #################################################
data "aws_secretsmanager_secret" "postgres" {
  name = "postgres-credentials"
}

data "aws_secretsmanager_secret_version" "postgres" {
  secret_id = data.aws_secretsmanager_secret.postgres.id
}

locals {
  postgres_secret = jsondecode(data.aws_secretsmanager_secret_version.postgres.secret_string)
}

resource "aws_db_instance" "postgres" { # 3m33s
  identifier             = "terraform-postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "15.3"
  username               = "postgres"
  password               = local.postgres_secret["password"]
  db_subnet_group_name   = aws_db_subnet_group.terraform_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}

resource "aws_security_group" "rds" { # 3s
  name   = "terraform_rds_security_group"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [module.eks.cluster_primary_security_group_id, module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "terraform_rds_subnet_group" { #1s
  name       = "terraform_rds_subnet_group"
  subnet_ids = module.vpc.private_subnets
}

output "db-endpoint" {
    value = aws_db_instance.postgres.endpoint
}

output "eks" {
  value     = module.eks
}
##################################################  Create EKS (11m 48s) ##################################################
# To get access: aws eks update-kubeconfig --name terraform-cluster --region us-west-1
module "eks" { # 11m 34.3926s 
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "terraform-cluster"
  cluster_version = "1.27"

  cluster_endpoint_public_access = true
  manage_aws_auth_configmap = true

  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      before_compute           = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  control_plane_subnet_ids = module.vpc.private_subnets

    # EKS Managed Node Group(s)
    eks_managed_node_group_defaults = {
      ami_type                   = "AL2_x86_64"
      instance_types             = ["t3.medium"]
      iam_role_attach_cni_policy = true
    }

    eks_managed_node_groups = {
        terraform_node_group = {
            min_size     = 2
            max_size     = 6
            desired_size =  2
        }
    }
    tags = {
        "elbv2.k8s.aws/cluster" = "true"
    }
}


module "vpc" { #2m 23s
  source = "terraform-aws-modules/vpc/aws"

  name = "terraform-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-1a", "us-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
##################################################  Creating deployment with ingress (2m 19s) ##################################################
resource "helm_release" "aws_load_balancer_controller" { #2m 1s
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_irsa_role.iam_role_arn
  }
}

resource "aws_iam_role_policy" "aws_load_balancer_controller_policy" { #1s
  name   = "aws-load-balancer-controller-policy"
  role   = module.aws_load_balancer_controller_irsa_role.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:AddTags",
        ],
        Effect   = "Allow",
        Resource = "*",
      }
    ]
  })
}


resource "kubernetes_ingress_v1" "ingress" { #1s
  metadata {
    name = "ingress"
    annotations = {
      "kubernetes.io/ingress.class"                 = "alb"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
    }
  }
  spec {
    default_backend {
      service {
        name = kubernetes_service.nodeport.metadata.0.name
        port {
          number = 80
        }
      }
    }
  }
}

resource "kubernetes_service" "nodeport" { #1s
  metadata {
    name = "node-port"
  }
  spec {
    selector = {
      App = kubernetes_deployment.demo_deployment.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "demo_deployment" { #2m 17s
  metadata {
    name = "deployment"
  }

  spec {
    selector {
      match_labels = {
        App = "spring-boot-demo"
      }
    }

    template {
      metadata {
        labels = {
          App = "spring-boot-demo"
        }
      }

      spec {
        container {
          image = "948243776115.dkr.ecr.us-west-1.amazonaws.com/springboot-repo"
          name  = "spring-boot-demo"
        }
      }
    }
  }
}

module "aws_load_balancer_controller_irsa_role" { #1s
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
   version = "~> 5.0"

  role_name = "aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

module "vpc_cni_irsa" { #5s
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

