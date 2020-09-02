terraform {
  required_version = ">= 0.12, < 0.13"
}

# https://www.terraform.io/docs/providers/openstack/index.html
# uses clouds.yml
provider "openstack" {
  cloud = var.os_cloud
  version = "~> 1.29"
}

provider "external" {
  version = "~> 1.2"
}

locals {
  rack_info = csvdecode(file(var.rack_info_csv))
  ips = { for node in local.rack_info: node.hardware_name => node.ip }
  names = { for node in local.rack_info: node.hardware_name => node.name }
}

resource "openstack_compute_instance_v2" "compute" {

  for_each = data.external.openstack_baremetal.result

  name = local.names[each.key]
  image_name = var.image_name
  flavor_name = var.flavor_name
  key_pair = var.key_pair
  config_drive = true
  availability_zone = "${var.availability_zone}::${each.value}"

  # TODO: just broke having more than one network
  dynamic "network" {
    for_each = var.networks

    content {
      name = network.value
      fixed_ip_v4 = local.ips[each.key]
    }
  }

  metadata = {
    "cluster" = var.cluster_name
  }
}

# TODO: needs fixing for case where creation partially fails resulting in "compute.network is empty list of object"
resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {"servers": openstack_compute_instance_v2.compute,
                           "groupname": var.inventory_groupname})
  filename = var.inventory_location
}
