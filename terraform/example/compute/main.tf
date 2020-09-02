terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "local" {
  version = "~> 1.4"
}

variable "rack" {
  type = string
}

locals {
  config = yamldecode(file("../config.yml"))
}

module "ironic_compute" {
  source = "../../modules/ironic_compute"

  os_cloud = local.config.os_cloud
  cluster_name = local.config.cluster_name
  image_name = local.config.compute.image_name
  flavor_name = local.config.compute.flavor_name
  key_pair = local.config.compute.key_pair
  networks = local.config.compute.networks

  rack_info_csv = "../${var.rack}.csv"
}

module "virtual_compute" {
  source = "../../modules/virtual_controller"

  os_cloud = local.config.os_cloud
  cluster_name = local.config.cluster_name

  image_name = local.config.controller.image_name
  flavor_name = local.config.controller.flavor_name

  key_pair = local.config.compute.key_pair
  networks = local.config.compute.networks

  hostname_prefix = "bk-computevm-"
  vm_count = 0
  inventory_location = "../inventory/vm_compute"
  inventory_groupname = "vm_compute"
}
