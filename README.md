# The Things Network LoRaWAN stack deployment

## How to use

### Prerequisites

You'll need:
- Terraform
- A Scaleway account to deploy the stack to

### What will happen

The following resources will be created:
- RDB instance
- Kapsule cluster
- Load Balancer

### Installing

1. Initialize terraform states with `tf init`
1. Deploy first terraform stage with `tf apply -target scaleway_k8s_pool_beta.ttn -target scaleway_rdb_instance_beta.ttndb`
1. Deploy next stages with `tf apply`

### Using

A lorawan-stack namespace have been created, and contains a LoadBalancer resource
which you can contact to access the ttn-lw stack software.
See https://www.thethingsindustries.com/docs/getting-started/ for more documentation.

## Contributing

See Scaleway contributing guide, ping me on slack (@didjcodt)
