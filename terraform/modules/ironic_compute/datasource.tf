data "external" "openstack_baremetal" {
    program = ["${path.module}/baremetal.py"]

    query = {
        os_cloud = var.os_cloud
        rack_info_csv = var.rack_info_csv
    }
}

