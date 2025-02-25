output "resources" {
  value = {
    vpc        = mgc_network_vpcs.vpc
    subnetpool = mgc_network_subnetpools.subnetpool
    subnet     = mgc_network_vpcs_subnets.subnet
  }
}
