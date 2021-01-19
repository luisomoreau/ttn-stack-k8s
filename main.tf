terraform {}

provider scaleway {
  zone   = "nl-ams-1"
  region = "nl-ams"
}

# Database
resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource scaleway_rdb_instance_beta ttndb {
  name          = "thethingsnetwork"
  node_type     = "db-dev-s"
  engine        = "PostgreSQL-12"
  is_ha_cluster = true
  user_name     = "root"
  password      = random_password.db_password.result
  tags          = ["ttn", "k8s"]
}

# Kapsule
resource scaleway_k8s_cluster_beta ttn {
  name    = "ttn"
  version = "1.20.2"
  cni     = "cilium"
  tags    = ["ttn", "k8s"]
}

resource scaleway_k8s_pool_beta ttn {
  cluster_id = scaleway_k8s_cluster_beta.ttn.id
  name       = "ttn"
  node_type  = "DEV1-M"
  size       = 3
}

# Infrastructure-dependent configs
provider "kubernetes" {
  load_config_file = "false"

  host  = scaleway_k8s_cluster_beta.ttn.kubeconfig[0].host
  token = scaleway_k8s_cluster_beta.ttn.kubeconfig[0].token
  cluster_ca_certificate = base64decode(
    scaleway_k8s_cluster_beta.ttn.kubeconfig[0].cluster_ca_certificate
  )
}

resource "kubernetes_namespace" "stack-namespace" {
  depends_on = [scaleway_k8s_pool_beta.ttn]
  metadata {
    name = "lorawan-stack"
  }
}

resource "kubernetes_namespace" "traefik-namespace" {
  depends_on = [scaleway_k8s_pool_beta.ttn]
  metadata {
    name = "traefik"
  }
}

resource "kubernetes_config_map" "ttndb" {
  metadata {
    name      = "db-config"
    namespace = "lorawan-stack"
  }

  data = {
    db_host_ip     = scaleway_rdb_instance_beta.ttndb.endpoint_ip
    db_host_port   = scaleway_rdb_instance_beta.ttndb.endpoint_port
    db_certificate = scaleway_rdb_instance_beta.ttndb.certificate
    db_user        = scaleway_rdb_instance_beta.ttndb.user_name
    db_password    = scaleway_rdb_instance_beta.ttndb.password
    db_db          = "rdb"
    db_uri         = "postgres://${scaleway_rdb_instance_beta.ttndb.user_name}:${urlencode(scaleway_rdb_instance_beta.ttndb.password)}@${scaleway_rdb_instance_beta.ttndb.endpoint_ip}:${scaleway_rdb_instance_beta.ttndb.endpoint_port}/rdb"
  }
}

# Save kubeconfig
resource "local_file" "kubeconfig" {
  depends_on = [scaleway_k8s_pool_beta.ttn]
  content    = scaleway_k8s_cluster_beta.ttn.kubeconfig[0].config_file
  filename   = "${path.module}/kubeconfig"
}
