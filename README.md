# INTRODUCTION

**PROJECT**: IaC (Infrastructure as a Code) with terraform for deploying azure resource group

## What Is Terraform?

Terraform is an infrastructure as code (IaC) tool that allows you to build, change, and version infrastructure safely and efficiently. This includes both low-level components like compute instances, storage, and networking, as well as high-level components like DNS entries and SaaS features.

## What Is MGC Network VPC?

VPC is a virtual network isolated behind of the Magalu Cloud infrastructure. This resource allow you execute yours resources with more security and privacy, with full control over the network environment.

[more](https://docs.magalu.cloud/docs/network/overview)

# NAMING CONVENTIONS

An effective naming convention consists of resource names from important information about each resource. A good name helps you quickly identify the resource's type, associated workload, environment, and the region hosting it.

In our environment we adopt the following convention:

| Business Cost Center (any characters) | Environment (3 characters and 1 number) | Azure Region (4 characters) | Resource Type (5 characters max) | Instance (3 characters) |
| ----------------------------------- | --------------------------------------- | --------------------------- | -------------------------------- | :---------------------: |

Environments possibles:

| Name        | Acronym | Description                                         |
| ----------- | ------- | --------------------------------------------------- |
| Production  | pro1    | Production Environment                              |
| Staging     | sta1    | Homologation Environment                            |
| Development | dev1    | Development Environment                             |
| Shared      | sha1    | Shared Environment                                  |
| hub         | hub1    | Transit Environment to network resources            |
| Spoke       | spk1    | Hub Environment to traffic requests to on-premisses |

Magalu Cloud Region (5 characters) according this table:

| ACRONYM | REGION            |
| ------- | ----------------- |
| `brse1`  | `br-se1`         |
| `brne1`  | `br-ne1`         |

For example, a virtual machine for a business costcenter called cliente01 for a production workload in the Brasil Sudeste Region might be cliente01-pro1-brse1-prj-001.

cliente01-pro1-brse1-prj-001

# INSTALL TERRAFORM

## Linux

### Ubuntu

```bash
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install terraform
  terraform version
```

### CentOS/RHEL/Oracle Linux

```bash
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
  sudo yum -y install terraform
  terraform version
```

## Windows

```powershell
 Invoke-WebRequest -Uri https://releases.hashicorp.com/terraform/1.1.9/terraform_1.1.9_windows_amd64.zip -OutFile terraform.zip
 Expand-Archive .\terraform.zip -DestinationPath C:\Windows\System32\ -Force
 terraform version
```

# AUTHENTICATING IN HASHICORP ENVIRONMENT

We are using hashicorp's SAAS to host the service states. By default, Terraform will obtain an API token and save it in plain text in a local CLI configuration file called credentials.tfrc.json. When you run terraform login, it will explain specifically where it intends to save the API token and give you a chance to cancel if the current configuration is not as desired.

You can get more details about these features from the following links:

[CLI Authentication](https://www.terraform.io/cli/auth)

[terraform login](https://www.terraform.io/cli/commands/login)

[CLI Configuration File](https://www.terraform.io/cli/config/config-file)

You can find the API Token that has already been generated in the environment in our keepass and configure your CLI as follows:

**In Windows**:

```powershell
@"
{
  "credentials": {
    "app.terraform.io": {
      "token": "SEE IN THE KEEPASS OR CONSULTE OURS ADMINS"
    }
  }
}
"@ | Set-Content ~\AppData\Roaming\terraform.d\credentials.tfrc.json
```

**In Linux**:

```bash
cat <<EOF | tee ~/.terraform.d/credentials.tfrc.json
{
  "credentials": {
    "app.terraform.io": {
      "token": "SEE IN THE KEEPASS OR CONSULTE OURS ADMINS"
    }
  }
}
EOF
```

# AUTHENTICATING IN MAGALU CLOUD

If workspace in Hashicorp's environment is configured to operate locally, you will need to authenticate to the API of the Magalu Cloud using an API KEY.

You can more information how to generate this API KEY in [Create API Key](https://docs.magalu.cloud/docs/devops-tools/api-keys/how-to/other-products/create-api-key)

In our environment we use the credentials as environment variables to autenticate in API of the Magalu Cloud, for example:

**Linux**:

```bash
  export MGC_API_KEY="00000000-0000-0000-0000-000000000000"
```

**Windows**:

```powershell
  $env:MGC_API_KEY="00000000-0000-0000-0000-000000000000"
```

To persist environment variables at user level

```powershell
  [System.Environment]::SetEnvironmentVariable("MGC_API_KEY","00000000-0000-0000-0000-000000000000","User")
```

To persist environment variables at machine level

```powershell
  [System.Environment]::SetEnvironmentVariable("MGC_API_KEY","00000000-0000-0000-0000-000000000000","Machine")
```

**ATTENTION**: On Linux operating systems it is not possible to persist environment variables

By declaring these environment variables, terraform will be able to authenticate through this SPN

# MODULE DOCUMENTATION

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_mgc"></a> [mgc](#requirement\_mgc) | 0.32.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mgc"></a> [mgc](#provider\_mgc) | 0.32.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mgc_network_subnetpools.subnetpool](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/network_subnetpools) | resource |
| [mgc_network_vpcs.vpc](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/network_vpcs) | resource |
| [mgc_network_vpcs_subnets.subnet](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/network_vpcs_subnets) | resource |
| [mgc_availability_zones.availability_zones](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | [REQUIRED] Name of an existing Project Name | `string` | n/a | yes |
| <a name="input_sequence"></a> [sequence](#input\_sequence) | [REQUIRED] Sequence to be used on resource naming. | `number` | `1` | no |
| <a name="input_subnet_pools"></a> [subnet\_pools](#input\_subnet\_pools) | [REQUIRED] The address space that is used the virtual network. You can supply more than one address space. CAUTION: Changing the existing address space recalculates all subnets. This action can harm the environment. | <pre>map(<br>    object(<br>      {<br>        ## - REQUIRED - SUBNET POO, ENABLED OR NO.<br>        enabled = bool<br>        ## REQUIRED - The description of the subnet pool.<br>        description = string<br>        ## OPTIONAL - The CIDR block of the subnet pool<br>        cidr = optional(string)<br>        ## REQUIRED - <br>        type = optional(string)<br>        ## REQUIRED - VPC<br>        vpcs = map(<br>          object(<br>            {<br>              enabled     = bool<br>              description = optional(string)<br>              ## REQUIRED - Network VPC Subnet<br>              subnets = map(<br>                object(<br>                  {<br>                    description     = optional(string)<br>                    enabled         = bool<br>                    dns_nameservers = optional(list(string))<br>                    ip_version      = string<br>                    mask            = number<br> order           = number<br>                  }<br>                )<br>              )<br>            }<br>          )<br>        )<br>      }<br>    )<br>  )</pre> | <pre>{<br>  "main": {<br>    "cidr": "10.0.0.0/16",<br>    "description": "Managed by Terraform (M1 Cloud).",<br>    "enabled": true,<br>    "vpcs": {<br>      "default": {<br>        "description": "Managed by Terraform.",<br>        "enabled": true,<br>        "subnets": {<br>          "zona1": {<br>            "dns_nameservers": [<br>              "8.8.8.8",<br>              "8.8.4.4"<br>            ],<br>            "enabled": true,<br>            "ip_version": "IPv4",<br>            "mask": 22,<br>            "order": 1<br>          }<br>        }<br>      }<br>    }<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resources"></a> [resources](#output\_resources) | n/a |

# DOCUMENTATION

Some of this documentation was generated through terraform-docs using the following command:

```bash
  docker run --rm --volume "$(pwd):/terraform-docs" quay.io/terraform-docs/terraform-docs:0.16.0 markdown /terraform-docs
```
