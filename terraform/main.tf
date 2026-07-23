terraform {
  required_version = ">= 1.15.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

variable "postgres_password" {
  type = string
  sensitive = true
}

resource "kubernetes_namespace_v1" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "kubernetes_secret_v1" "postgres_password" {
  metadata {
    name = "postgres-password"
    namespace = "postgres"
  }

  data = {
    POSTGRES_PASSWORD = trimspace(var.postgres_password)
  }

  type = "Opaque"
}

resource "helm_release" "postgres" {
  name = "postgres"
  repository = "oci://ghcr.io/11notes/charts"
  chart = "postgres"
  namespace  = "postgres"
  version = "1.0.0"
  create_namespace = false

  values = [
    yamlencode({
      image = {
        tag: "18"
      }
      postgres = {
        existingSecret    = "postgres-password"
        existingSecretKey = "POSTGRES_PASSWORD"
      }
      persistence = {
        etc = {
          size = "16Mi"
        }
        var = {
          size = "32Gi"
        }
      }
    })
  ]
}