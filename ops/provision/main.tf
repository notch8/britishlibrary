terraform {
  backend "pg" {}
  required_version = ">= 0.13"

  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
      version = "1.11.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

variable "region" {
  default     = "eu-west-1"
  description = "AWS region"
}


provider "helm" {
  kubernetes {
    config_path = "kube_config.yml"
  }
}

provider "kubectl" {
  config_path = "kube_config.yml"
}

provider "kubernetes" {
  config_path = "kube_config.yml"
}

data "local_file" "efs_name" {
  filename = "efs_name"
}

resource "helm_release" "aws-load-balancer" {
  chart   = "aws-load-balancer-controller"
  name    = "aws-load-balancer-controller"
  namespace = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  set {
    name = "clusterName"
    value = "r2-bl"
  }
}

resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"
  namespace = "ingress-nginx"
  create_namespace = true
  version = "4.5.2"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  depends_on = [helm_release.aws-load-balancer]
  values = [
    file("k8s/ingress-nginx-values.yaml")
  ]
}

resource "kubernetes_storage_class" "storage_class" {
  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    directoryPerms   = "700"
    fileSystemId     = trimspace(data.local_file.efs_name.content)
    provisioningMode = "efs-ap"
  }

  metadata {
    name = "efs-sc"
  }
}

resource "helm_release" "cert_manager" {
  name = "cert-manager"
  namespace = "cert-manager"
  create_namespace = true
  version = "1.12.0"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubectl_manifest" "prod_issuer" {
  depends_on = [helm_release.cert_manager]
  yaml_body = file("./k8s/prod_issuer.yaml")
}

resource "kubectl_manifest" "prod_issuer_dns" {
  depends_on = [helm_release.cert_manager]
  yaml_body = file("./k8s/prod-issuer-dns-values.yaml")
}

resource "kubectl_manifest" "staging_issuer" {
  depends_on = [helm_release.cert_manager]
  yaml_body = file("./k8s/staging_issuer.yaml")
}

resource "kubectl_manifest" "redirect" {
  for_each = fileset("./k8s/redirects", "*.yaml")

  depends_on = [helm_release.cert_manager]
  yaml_body = file("./k8s/redirects/${each.value}")
}

resource "helm_release" "postgresql" {
  name = "postgresql"
  namespace = "default"
  create_namespace = true
  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  values = [
    file("k8s/postgresql-values.yaml")
  ]
}

resource "helm_release" "postgresql-fcrepo" {
  name = "postgresql"
  namespace = "fcrepo"
  create_namespace = true
  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  values = [
    file("k8s/postgresql-values.yaml")
  ]
}

resource "helm_release" "postgresql-fcrepo-staging" {
  name = "postgresql"
  namespace = "fcrepo-staging"
  create_namespace = true
  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  values = [
    file("k8s/postgresql-values.yaml")
  ]
}

resource "helm_release" "fcrepos3" {
  depends_on = [helm_release.postgresql-fcrepo]

  name = "fcrepo"
  namespace = "fcrepo"
  create_namespace = true
  repository = "https://samvera-labs.github.io/fcrepo-charts"
  chart = "fcrepo"
  values = [
    file("k8s/fcrepos3-values.yaml")
  ]

}

resource "helm_release" "fcrepos3-staging" {
  depends_on = [helm_release.postgresql-fcrepo-staging]

  name = "fcrepo-staging"
  namespace = "fcrepo-staging"
  create_namespace = true
  repository = "https://samvera-labs.github.io/fcrepo-charts"
  chart = "fcrepo"
  values = [
    file("k8s/fcrepos3-values.yaml")
  ]

}

resource "helm_release" "solr" {
  name = "solr"
  namespace = "default"
  create_namespace = true
  repository = "https://charts.bitnami.com/bitnami"
  chart = "solr"
  values = [
    file("k8s/solr-values.yaml")
  ]
}

resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
    annotations = {
      "cattle.io/status" = jsonencode(
        {
          Conditions = [
            {
              LastUpdateTime = "2022-02-10T05:23:42Z"
              Message        = ""
              Status         = "True"
              Type           = "ResourceQuotaInit"
            },
            {
              LastUpdateTime = "2022-02-10T05:23:43Z"
              Message        = ""
              Status         = "True"
              Type           = "InitialRolesPopulated"
            }
          ]
        }
        )
      "lifecycle.cattle.io/create.namespace-auth" = "true"
      "field.cattle.io/projectId"                 = "c-6p4jv:p-98kns"
    }
    labels           = {
      "field.cattle.io/projectId" = "p-98kns"
    }
  }
}

resource "kubernetes_namespace" "productionn" {
  metadata {
    name = "production"
    annotations      = {
      "cattle.io/status" = jsonencode(
        {
          Conditions = [
            {
              LastUpdateTime = "2022-02-10T05:23:42Z"
              Message        = ""
              Status         = "True"
              Type           = "ResourceQuotaInit"
            },
            {
              LastUpdateTime = "2022-02-10T05:23:43Z"
              Message        = ""
              Status         = "True"
              Type           = "InitialRolesPopulated"
            }
          ]
        }
        )
      "lifecycle.cattle.io/create.namespace-auth" = "true"
      "field.cattle.io/projectId"                 = "c-6p4jv:p-98kns"
    }
    labels           = {
      "field.cattle.io/projectId" = "p-98kns"
    }
  }
}

resource "kubectl_manifest" "gitlab-secrets" {
  depends_on = [helm_release.cert_manager]
  yaml_body = file("k8s/gitlab-secret-values.yaml")
}
