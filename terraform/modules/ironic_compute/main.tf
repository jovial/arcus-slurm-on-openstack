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

resource "openstack_compute_instance_v2" "compute" {

  for_each = data.external.openstack_baremetal.result

  name = "${var.hostname_prefix}${each.key}"
  image_name = var.image_name
  flavor_name = var.flavor_name
  key_pair = var.key_pair
  config_drive = true
  availability_zone = "${var.availability_zone}::${each.value}"

  dynamic "network" {
    for_each = var.networks

    content {
      name = network.value
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
