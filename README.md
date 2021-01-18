# The Things Network LoRaWAN stack deployment

## How to use

### Prerequisites

You'll need:
- A Scaleway account to deploy the stack to
- Terraform & kubectl installed locally
- A domain name

### What will happen

The following resources will be created:
- RDB instance
- Kapsule cluster
- Load Balancer
- Two block Storages of 2GB each

### Setting up environment

1. Configure Terraform Provider authentication with Scaleway credentials: [https://registry.terraform.io/providers/scaleway/scaleway/latest/docs#authentication](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs#authentication)
1. Clone this repository

### Installing

1. Initialize terraform states with `tf init`
1. Deploy terraform resources with `tf apply`
1. Configure the following files with your mail/FQDN/etc.:
   - manifests/ttn-stack/ttn-lw-stack-docker.yaml
   - manifests/ttn-stack/ingress.yaml
   - manifests/cert-manager/cert-issuer.yaml
   - manifests/grafana/ingress.yaml
1. Import the generated kubeconfig file with `export KUBECONFIG=$(pwd)/kubeconfig`
1. Deploy the cert-manager with `kubectl apply -f manifests/cert-manager`
1. Deploy TTN stack with `kubectl apply -k manifests`

1. Execute the following commands (do not forget to replace `ttn-lw-stack-xxxxxxxxxxx-xxxx` with your pod and `your-email@tld.com` with your email):

```
$> kubectl get pods -n lorawan-stack
NAME                            READY   STATUS    RESTARTS   AGE
redis-cc5fcd64f-5gsr6           1/1     Running   0          2m43s
ttn-lw-stack-xxxxxxxxxxx-xxxx   1/1     Running   1          2m40s
```


```
$> kubectl exec -ti -n lorawan-stack ttn-lw-stack-xxxxxxxxxx-xxxxx -- ttn-lw-stack is-db create-admin-user \
--id admin \
--email your-email@tld.com
```

```
$> kubectl exec -ti -n lorawan-stack ttn-lw-stack-xxxxxxxxxx-xxxxx -- ttn-lw-stack is-db create-oauth-client \
 --id cli \
 --name "Command Line Interface" \
 --owner admin \
 --no-secret \
 --redirect-uri "local-callback" \
 --redirect-uri "code"
```

```
$> kubectl exec -ti -n lorawan-stack ttn-lw-stack-xxxxxxxxxx-xxxxx -- ttn-lw-stack is-db create-oauth-client  --id console  --name "Console"  --owner admin  --secret "console"  --redirect-uri "https://ttn.louismoreau.eu/console/oauth/callback"  --redirect-uri "/console/oauth/callback"  --logout-redirect-uri "https://ttn.louismoreau.eu/console"  --logout-redirect-uri "/console"
```


### Using

A lorawan-stack namespace have been created, and contains a LoadBalancer resource
which you can contact to access the ttn-lw stack software.
See https://www.thethingsindustries.com/docs/getting-started/ for more documentation.

## How it works

The repository looks something like this:
```
.
├── README.md
├── main.tf
├── manifests
│   ├── kustomization.yaml
│   ├── cert-manager
│   │   └── *.yaml
│   ├── redis
│   │   └── *.yaml
│   ├── traefik
│   │   └── *.yaml
│   ├── ttn-lw-stack-docker.yaml
│   └── ttn-stack
│       └── *.yaml
├── providers.tf
└── versions.tf
```

When calling `tf init`, terraform gets the necessary plugins, and creates the
base state files.  After, calling the `tf apply` uses mainly `main.tf` which
creates the infrastructure resources (RDB instance, Kapsule cluster). It also
saves the kubeconfig file in the root folder of the git repository and creates
the necessary namespaces in the cluster.

The cluster bootstrap is done in two stages:
- Installation of the dependencies:
  o cert-manager for certificates management
  o traefik as kubernetes ingress controller
  o redis for storage and caching
- Installation of TTN stack

## Contributing

See Scaleway contributing guide, ping me on slack (@didjcodt)
