###############################
# .BASICS VARIABLES
variable "project_name" {
  type        = string
  description = "[REQUIRED] Name of an existing Project Name"

  validation {
    condition     = length(split("-", var.project_name)) == 5
    error_message = "Workspace Name cant respect naming conventions. In README.md we shown how to create a name to environment."
  }

  validation {
    condition     = can(regex("^[a-z]{3}\\d{1}$", split("-", var.project_name)[1]))
    error_message = "Environment defined in Name of the Workspace cant respect naming conventions. In README.md we shown how to create a name to environment."
  }

  validation {
    condition     = contains(["pro", "sta", "dev", "sha", "hub", "spk"], substr(split("-", var.project_name)[1], 0, 3))
    error_message = "Environment defined in Name of the Workspace cant respect naming conventions. The allowed values are: `pro`, `sta`, `dev`, `sha`, `hub` or `spk`."
  }

  validation {
    condition     = contains(["brse1", "brne1"], split("-", var.project_name)[2])
    error_message = "Region defined wihtout support in ours services. Only regions US and Brazil are permited. The allowed values are: `brse1` or `brne1`."
  }

  validation {
    condition     = length(split("-", var.project_name)[4]) == 3
    error_message = "Workspace Sequence cant respect naming conventions. The variable Worskapce Sequence be 3 (three) algarisms."
  }

  validation {
    condition     = tonumber(split("-", var.project_name)[4]) > 0 && tonumber(split("-", var.project_name)[4]) <= 999
    error_message = "Workspace Sequence cant respect naming conventions. The variable Worskapce Sequence be between 1 and 999."
  }
}

variable "sequence" {
  type        = number
  description = "[REQUIRED] Sequence to be used on resource naming."
  default     = 1
  validation {
    condition     = var.sequence > 0 && var.sequence <= 999
    error_message = "The variable sequence must be between 1 and 999."
  }
}

###############################
# .MODULE VARIABLE RESOURCES
variable "subnet_pools" {
  type = map(
    object(
      {
        ## - REQUIRED - SUBNET POO, ENABLED OR NO.
        enabled = bool
        ## REQUIRED - The description of the subnet pool.
        description = string
        ## OPTIONAL - The CIDR block of the subnet pool
        cidr = optional(string)
        ## REQUIRED - 
        type = optional(string)
        ## REQUIRED - VPC
        vpcs = map(
          object(
            {
              enabled     = bool
              description = optional(string)
              ## REQUIRED - Network VPC Subnet
              subnets = map(
                object(
                  {
                    description     = optional(string)
                    enabled         = bool
                    dns_nameservers = optional(list(string))
                    ip_version      = string
                    mask            = number
                    order           = number
                  }
                )
              )
            }
          )
        )
      }
    )
  )
  description = "[REQUIRED] The address space that is used the virtual network. You can supply more than one address space. CAUTION: Changing the existing address space recalculates all subnets. This action can harm the environment."
  default = {
    "main" = {
      enabled     = true
      description = "Managed by Terraform (M1 Cloud)."
      cidr        = "10.0.0.0/16"
      vpcs = {
        "default" = {
          description = "Managed by Terraform."
          enabled     = true
          subnets = {
            "zona1" = {
              dns_nameservers = ["8.8.8.8", "8.8.4.4"]
              enabled         = true
              ip_version      = "IPv4"
              mask            = 22
              order           = 1
            }
          }
        }
      }
    }
  }

  validation {
    condition = alltrue([
      for v in var.subnet_pools : can(cidrhost(v.cidr, 32))
    ])
    error_message = "[ERROR] Must be valid IPv4 CIDR."
  }

  validation {
    condition = alltrue(
      flatten(
        [
          for v in var.subnet_pools : [
            for vpc in v.vpcs : [
              for subnet in vpc.subnets : subnet.mask >= 8 && subnet.mask <= 30
            ]
          ]
        ]
      )
    )
    error_message = "[ERROR] Must be valid Mask. The value must be between 8 and 30."
  }

  validation {
    condition = alltrue(
      flatten([
        for v in var.subnet_pools : [
          for vpc in v.vpcs : [
            for subnet in vpc.subnets : contains(["IPv4", "IPv6"], subnet.ip_version)
          ]
        ]
      ])
    )
    error_message = "[ERROR] The value must be IPv4 or IPv6."
  }

}

