locals {
  resource_name_partial    = substr(var.project_name, 0, length(var.project_name) - 3)
  resource_name            = "${replace(local.resource_name_partial, "mgc", "vpc")}${format("%03d", var.sequence)}"
  resource_name_subnetpool = "${replace(local.resource_name_partial, "mgc", "snetpool")}${format("%03d", var.sequence)}"
  resource_name_subnet     = "${replace(local.resource_name_partial, "mgc", "snet")}${format("%03d", var.sequence)}"

  ## OBTENDO LISTA DE VPCs
  vpcs = flatten(
    [
      for k1, v1 in var.subnet_pools : [
        for k2, v2 in v1.vpcs : {
          subnet_pool_key = k1
          key             = k2
          description     = v2.description
        } if v2.enabled
      ]
    ]
  )

  ## TRANSFORMANDO O SUBNETPOOL COM SUAS RESPECTIVAS SUBNETS EM UMA LISTA CHAVE => VALOR
  subnets = flatten(
    [
      for k1, v1 in var.subnet_pools : [
        for k2, v2 in v1.vpcs : {
          for subnet_key, subnet_value in v2.subnets : format("%04d-%s-%s-%s", subnet_value.order, k1, k2, subnet_key) => {
            subnet_pool_key         = k1
            vpc_key                 = k2
            vpc_description         = v2.description
            subnet_pool_cidr        = v1.cidr
            subnet_pool_description = v1.description
            subnet_description      = subnet_value.description
            subnet_dns_nameservers  = subnet_value.dns_nameservers
            subnet_mask             = subnet_value.mask
            subnet_ip_version       = subnet_value.ip_version
          } if subnet_value.enabled
        } if v2.enabled
      ] if v1.enabled
    ]
  )

  ## - DEFININDO AS SUB-REDES
  newbits = flatten([for v in local.subnets[0] : tonumber(v.subnet_mask - split("/", v.subnet_pool_cidr)[1])])

  address_prefixes = flatten([
    for value in var.subnet_pools : cidrsubnets(value.cidr, local.newbits[*]...)
  ])

  address_prefixes_object = {
    for key, value in local.subnets[0] : key => local.address_prefixes[index(keys(local.subnets[0]), key)]
  }

  ## - UNIFICANDO TUDO EM UM UNICO OBJETO JA ORGANIZADO COM SEUS RESPECTIVOS ENDEREÇOS DE SUB-REDES
  all_subnets_with_cidr = {
    for key, subnet in local.subnets[0] : key => merge({ cidr = [local.address_prefixes_object[key]] }, subnet)
  }

}

#####################
## - GET REQUIREMENTS
data "mgc_availability_zones" "availability_zones" {}

#####################
## - RESOURCES
resource "mgc_network_subnetpools" "subnetpool" {
  for_each = { for k, v in var.subnet_pools : k => v if v.enabled }
  # for_each = { for k, v in local.all_subnets_with_cidr : k => v }

  name        = "${local.resource_name_subnetpool}-${each.key}"
  description = each.value.description
  cidr        = each.value.cidr
  type        = each.value.type == null ? "pip" : each.value.type
}

resource "mgc_network_vpcs" "vpc" {
  for_each = { for v in local.vpcs : v.key => v }

  name        = "${local.resource_name}-${each.key}"
  description = each.value.description
}

resource "mgc_network_vpcs_subnets" "subnet" {
  for_each = { for k, v in local.all_subnets_with_cidr : k => v }

  cidr_block      = each.value.cidr[0]
  description     = each.value.subnet_description
  dns_nameservers = each.value.subnet_dns_nameservers
  ip_version      = each.value.subnet_ip_version
  name            = "${local.resource_name_subnet}-${each.key}"
  subnetpool_id   = mgc_network_subnetpools.subnetpool[each.value.subnet_pool_key].id
  vpc_id          = mgc_network_vpcs.vpc[each.value.vpc_key].id
}
