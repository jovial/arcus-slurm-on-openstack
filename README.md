# arcus-slurm-on-openstack

## Requirements

### clouds.yaml

It is necessary to have a working clouds.yaml. This file should
then be placed in `~/.config/openstack/clouds.yaml`. Please see this
[link](https://docs.openstack.org/python-openstackclient/ussuri/configuration/index.html) for more
details.

## Terraform

The terraform tool must be installed and in your PATH. Installation instructions can be found [here](https://www.terraform.io/downloads.html).

## Create infrastructure

Typically you first create the infrastructure using terraform.
The terraform generates an ansible inventory for the next step.

### Terraform configuration

Environment specific details are set using a yaml configuration file.
Terraform takes this file as input. Please see this [example](terraform/example/config.yml)
for inspiration.

You must also provide a CSV file describing the servers you wish to provision. The headings
should appear as the first line in the file. The following fields are required:

- `name`: name of instance that is deployed
- `hardware_name`: the name of the node in ironic
- `ip`: Use a fixed IP when provisioning the node

The CSV file that terraform uses is determined by the `rack` variable. It will attempt
to read `${var.rack}.csv`. This allows you to reuse the same terraform configuration
across multiple racks.

An example CSV file can be seen here:

```
dc,rack,rack_pos,height,hardware_name,manufacturer,model,serial,name,ip,mac_noformat,mac,bmc_ip,bmc_mac_noformat,bmc_mac,pxe_bootstrap_ip,nodetype,groups,s3048_port,sn3700c_port
WCDC-DH1,DR06,33,1,sv-b17-u29,Dell,C6420,GVX3,cpu-p-1,10.60.253.61,,,,,,,server,"all,nodes,cascadelake,csd3,compute-csd3,compute-cascadelake,Dell,C6420,csd3-2020q3p1,csd3-2020q3p1-dr06",ethsw-dr06-u20-p3,ethsw-dr06-u19-swp2s0
WCDC-DH1,DR06,34,1,sv-b16-u6,Dell,C6420,FVX3,cpu-p-2,10.60.253.62,,,,,,,server,"all,nodes,cascadelake,csd3,compute-csd3,compute-cascadelake,Dell,C6420,csd3-2020q3p1,csd3-2020q3p1-dr06",ethsw-dr06-u20-p4,ethsw-dr06-u19-swp2s1
```

### Running terraform

For each class of node (compute, controller) you need to initialise terraform:

```
[will@dev-director compute]$ pwd
/opt2/will/arcus-slurm-on-openstack/terraform/example/compute
[will@dev-director compute]$ terraform init
Initializing modules...
- ironic_compute in ../../modules/ironic_compute
- virtual_compute in ../../modules/virtual_controller

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "openstack" (terraform-providers/openstack) 1.31.0...
- Downloading plugin for provider "external" (hashicorp/external) 1.2.0...
- Downloading plugin for provider "local" (hashicorp/local) 1.4.0...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

This will download all the necessary plugins.

It is advsiable to run a `plan` operation to see which resources would be created:

```

[will@dev-director compute]$ terraform plan
var.rack
  Enter a value: rack1

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.ironic_compute.data.external.openstack_baremetal: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.ironic_compute.local_file.hosts will be created
  + resource "local_file" "hosts" {
      + content              = <<~EOT
            [baremetal_compute]
            cpu-p-2 ansible_host=10.60.253.62 server_networks='{"ilab":["10.60.253.62"]}'
            cpu-p-1 ansible_host=10.60.253.61 server_networks='{"ilab":["10.60.253.61"]}'
        EOT
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../inventory/baremetal_compute"
      + id                   = (known after apply)
    }

  # module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"] will be created
  + resource "openstack_compute_instance_v2" "compute" {
      + access_ip_v4        = (known after apply)
      + access_ip_v6        = (known after apply)
      + all_metadata        = (known after apply)
      + all_tags            = (known after apply)
      + availability_zone   = "nova::720d9d7d-e7d9-46e7-8346-7b0dae61dc36"
      + config_drive        = true
      + flavor_id           = (known after apply)
      + flavor_name         = "compute-A"
      + force_delete        = false
      + id                  = (known after apply)
      + image_id            = (known after apply)
      + image_name          = "CentOS7"
      + key_pair            = "ilab_sclt100"
      + metadata            = {
          + "cluster" = "wjs"
        }
      + name                = "cpu-p-2"
      + power_state         = "active"
      + region              = (known after apply)
      + security_groups     = (known after apply)
      + stop_before_destroy = false

      + network {
          + access_network = false
          + fixed_ip_v4    = "10.60.253.62"
          + fixed_ip_v6    = (known after apply)
          + floating_ip    = (known after apply)
          + mac            = (known after apply)
          + name           = "ilab"
          + port           = (known after apply)
          + uuid           = (known after apply)
        }
    }

  # module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"] will be created
  + resource "openstack_compute_instance_v2" "compute" {
      + access_ip_v4        = (known after apply)
      + access_ip_v6        = (known after apply)
      + all_metadata        = (known after apply)
      + all_tags            = (known after apply)
      + availability_zone   = "nova::43543d55-d442-411a-95b0-432dd276f497"
      + config_drive        = true
      + flavor_id           = (known after apply)
      + flavor_name         = "compute-A"
      + force_delete        = false
      + id                  = (known after apply)
      + image_id            = (known after apply)
      + image_name          = "CentOS7"
      + key_pair            = "ilab_sclt100"
      + metadata            = {
          + "cluster" = "wjs"
        }
      + name                = "cpu-p-1"
      + power_state         = "active"
      + region              = (known after apply)
      + security_groups     = (known after apply)
      + stop_before_destroy = false

      + network {
          + access_network = false
          + fixed_ip_v4    = "10.60.253.61"
          + fixed_ip_v6    = (known after apply)
          + floating_ip    = (known after apply)
          + mac            = (known after apply)
          + name           = "ilab"
          + port           = (known after apply)
          + uuid           = (known after apply)
        }
    }

  # module.virtual_compute.local_file.hosts will be created
  + resource "local_file" "hosts" {
      + content              = <<~EOT
            [vm_compute]
        EOT
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../inventory/vm_compute"
      + id                   = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

NOTE: that it prompted for the value of `rack`.

If you are happy, provision the servers with:

```
[will@dev-director compute]$ terraform apply
var.rack
  Enter a value: rack1

module.ironic_compute.data.external.openstack_baremetal: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.ironic_compute.local_file.hosts will be created
  + resource "local_file" "hosts" {
      + content              = <<~EOT
            [baremetal_compute]
            cpu-p-2 ansible_host=10.60.253.62 server_networks='{"ilab":["10.60.253.62"]}'
            cpu-p-1 ansible_host=10.60.253.61 server_networks='{"ilab":["10.60.253.61"]}'
        EOT
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../inventory/baremetal_compute"
      + id                   = (known after apply)
    }

  # module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"] will be created
  + resource "openstack_compute_instance_v2" "compute" {
      + access_ip_v4        = (known after apply)
      + access_ip_v6        = (known after apply)
      + all_metadata        = (known after apply)
      + all_tags            = (known after apply)
      + availability_zone   = "nova::720d9d7d-e7d9-46e7-8346-7b0dae61dc36"
      + config_drive        = true
      + flavor_id           = (known after apply)
      + flavor_name         = "compute-A"
      + force_delete        = false
      + id                  = (known after apply)
      + image_id            = (known after apply)
      + image_name          = "CentOS7"
      + key_pair            = "ilab_sclt100"
      + metadata            = {
          + "cluster" = "wjs"
        }
      + name                = "cpu-p-2"
      + power_state         = "active"
      + region              = (known after apply)
      + security_groups     = (known after apply)
      + stop_before_destroy = false

      + network {
          + access_network = false
          + fixed_ip_v4    = "10.60.253.62"
          + fixed_ip_v6    = (known after apply)
          + floating_ip    = (known after apply)
          + mac            = (known after apply)
          + name           = "ilab"
          + port           = (known after apply)
          + uuid           = (known after apply)
        }
    }

  # module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"] will be created
  + resource "openstack_compute_instance_v2" "compute" {
      + access_ip_v4        = (known after apply)
      + access_ip_v6        = (known after apply)
      + all_metadata        = (known after apply)
      + all_tags            = (known after apply)
      + availability_zone   = "nova::43543d55-d442-411a-95b0-432dd276f497"
      + config_drive        = true
      + flavor_id           = (known after apply)
      + flavor_name         = "compute-A"
      + force_delete        = false
      + id                  = (known after apply)
      + image_id            = (known after apply)
      + image_name          = "CentOS7"
      + key_pair            = "ilab_sclt100"
      + metadata            = {
          + "cluster" = "wjs"
        }
      + name                = "cpu-p-1"
      + power_state         = "active"
      + region              = (known after apply)
      + security_groups     = (known after apply)
      + stop_before_destroy = false

      + network {
          + access_network = false
          + fixed_ip_v4    = "10.60.253.61"
          + fixed_ip_v6    = (known after apply)
          + floating_ip    = (known after apply)
          + mac            = (known after apply)
          + name           = "ilab"
          + port           = (known after apply)
          + uuid           = (known after apply)
        }
    }

  # module.virtual_compute.local_file.hosts will be created
  + resource "local_file" "hosts" {
      + content              = <<~EOT
            [vm_compute]
        EOT
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../inventory/vm_compute"
      + id                   = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.virtual_compute.local_file.hosts: Creating...
module.virtual_compute.local_file.hosts: Creation complete after 0s [id=37aa0ffc23ea187b38783c0b6911e56f7f7ddaee]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Creating...
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Creating...
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [10s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [10s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [20s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [20s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [30s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [30s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [40s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [40s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [50s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [50s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [1m0s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [1m0s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [1m10s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [1m10s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [1m20s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [1m20s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [1m30s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [1m30s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [1m40s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [1m40s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [1m50s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [1m50s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [2m0s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [2m0s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [2m10s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [2m10s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [2m20s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [2m20s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [2m30s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [2m30s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [2m40s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [2m40s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [2m50s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [2m50s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [3m0s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [3m0s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [3m10s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [3m10s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [3m20s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [3m20s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [3m30s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [3m30s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [3m40s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [3m40s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [3m50s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [3m50s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [4m0s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [4m0s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [4m10s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [4m10s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [4m20s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [4m20s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [4m30s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [4m30s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [4m40s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [4m40s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [4m50s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [4m50s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [5m0s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [5m0s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [5m10s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [5m10s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [5m20s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [5m20s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [5m30s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [5m30s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [5m40s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [5m40s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [5m50s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [5m50s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Still creating... [6m0s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Still creating... [6m0s elapsed]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b17-u29"]: Creation complete after 6m9s [id=157872e3-1a43-42d9-a452-5bf87817d1b2]
module.ironic_compute.openstack_compute_instance_v2.compute["sv-b16-u6"]: Creation complete after 6m9s [id=eddb24e7-c5a4-40a1-842d-a07a05c9deaa]
module.ironic_compute.local_file.hosts: Creating...
module.ironic_compute.local_file.hosts: Creation complete after 0s [id=4609a6f288a37d6462f54eab9a37d5cf6aea176f]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

ironic_computes = {
  "sv-b16-u6" = {
    "access_ip_v4" = "10.60.253.62"
    "access_ip_v6" = ""
    "all_metadata" = {
      "cluster" = "wjs"
    }
    "all_tags" = []
    "availability_zone" = "nova"
    "block_device" = []
    "config_drive" = true
    "flavor_id" = "b7bdadfa-83a0-46a1-a854-f780b9d296c3"
    "flavor_name" = "compute-A"
    "force_delete" = false
    "id" = "eddb24e7-c5a4-40a1-842d-a07a05c9deaa"
    "image_id" = "c6c279a8-0746-40ec-9dad-9e76c7ed2bf9"
    "image_name" = "CentOS7"
    "key_pair" = "ilab_sclt100"
    "metadata" = {
      "cluster" = "wjs"
    }
    "name" = "cpu-p-2"
    "network" = [
      {
        "access_network" = false
        "fixed_ip_v4" = "10.60.253.62"
        "fixed_ip_v6" = ""
        "floating_ip" = ""
        "mac" = "24:6e:96:48:91:38"
        "name" = "ilab"
        "port" = ""
        "uuid" = "e0840c22-a899-4f29-bf9c-c33feef08d88"
      },
    ]
    "personality" = []
    "power_state" = "active"
    "region" = "RegionOne"
    "scheduler_hints" = []
    "security_groups" = [
      "default",
    ]
    "stop_before_destroy" = false
    "vendor_options" = []
    "volume" = []
  }
  "sv-b17-u29" = {
    "access_ip_v4" = "10.60.253.61"
    "access_ip_v6" = ""
    "all_metadata" = {
      "cluster" = "wjs"
    }
    "all_tags" = []
    "availability_zone" = "nova"
    "block_device" = []
    "config_drive" = true
    "flavor_id" = "b7bdadfa-83a0-46a1-a854-f780b9d296c3"
    "flavor_name" = "compute-A"
    "force_delete" = false
    "id" = "157872e3-1a43-42d9-a452-5bf87817d1b2"
    "image_id" = "c6c279a8-0746-40ec-9dad-9e76c7ed2bf9"
    "image_name" = "CentOS7"
    "key_pair" = "ilab_sclt100"
    "metadata" = {
      "cluster" = "wjs"
    }
    "name" = "cpu-p-1"
    "network" = [
      {
        "access_network" = false
        "fixed_ip_v4" = "10.60.253.61"
        "fixed_ip_v6" = ""
        "floating_ip" = ""
        "mac" = "24:6e:96:48:89:f8"
        "name" = "ilab"
        "port" = ""
        "uuid" = "e0840c22-a899-4f29-bf9c-c33feef08d88"
      },
    ]
    "personality" = []
    "power_state" = "active"
    "region" = "RegionOne"
    "scheduler_hints" = []
    "security_groups" = [
      "default",
    ]
    "stop_before_destroy" = false
    "vendor_options" = []
    "volume" = []
  }
}
```

Look for the inventory that has been generated. This is required for the ansible configuration
step. You can find the location from the output of `terraform apply`:

```
  # module.ironic_compute.local_file.hosts will be created
  + resource "local_file" "hosts" {
      + content              = <<~EOT
            [baremetal_compute]
            cpu-p-2 ansible_host=10.60.253.62 server_networks='{"ilab":["10.60.253.62"]}'
            cpu-p-1 ansible_host=10.60.253.61 server_networks='{"ilab":["10.60.253.61"]}'
        EOT
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../inventory/baremetal_compute"
      + id                   = (known after apply)
    }
```
HINT: look for the filename key.

You should repeat the process for the controller group. By the end of the process:

- All nodes will have been provisioned
- An inventory file for the slurm computes should have been created
- An inventory file for the slurm controller should have been created

You will need the paths of the inventory files for the ansible configuration step.

## Ansible to configure infrastructure

All of the ansible configuration, as well as the playbooks to drive the slurm installation
can be found in the `ansible` subdirectory of this repository. The hierarchy is:

- `ansible/hosts`: Contains the ansible inventory. Files in this subdirectory describe the servers you have provisioned with terraform.
- `ansible/roles`: The roles necessary to run the playbooks are downloaded here by the ansible-galaxy tool.

### Configuration

Customise the inventory to include the inventory files that were generated in the `Create infrastructure` step. You can use symlinks or simply copy the files into place. Here is an example using symlinks:

```
/opt2/will/arcus-slurm-on-openstack/ansible/hosts
[will@dev-director hosts]$ ls -lia
total 12
15744037 drwxrwxr-x. 2 will will 4096 Sep 16 13:59 .
15744028 drwxrwxr-x. 6 will will 4096 Sep 16 15:40 ..
15744102 lrwxrwxrwx. 1 will will   51 Jul  6 18:03 baremetal_compute -> ../../terraform/example/inventory/baremetal_compute
15744039 -rw-rw-r--. 1 will will  156 Jul  6 18:03 groups
15744040 lrwxrwxrwx. 1 will will   44 Jul  6 17:10 login -> ../../terraform/example/inventory/controller
```

You are now ready to run the playbooks to deploy slurm.

### Running the playbooks

The ansible creates a slurm cluster, and adds an NFS server on
the login node.
```
cd ansible
python3 -m venv .venv
. .venv/bin/activate
pip install -U pip
pip install "ansible<2.10"

ansible-galaxy install -r requirements.yml

ansible-playbook main.yml
```

## Building the OpenHPC image

The above slurm environment includes a custom slurm reboot script:
https://github.com/stackhpc/slurm-openstack-tools

It allows you to update a Slurm cluster using the following:
```
scontrol reboot [ASAP] reason="rebuild image:<image_id>" [<NODES>]
```

To create the image, we have an image-build playbook:

* First load your openstack credentials into your environment.
  This is necessary so that the script can upload the images to glance:
```
source ~/openrc
```

* Run the playbook to build the image:
```
cd <GIT_CHECKOUT>/ansible/
ansible-galaxy install -r requirements.yml -p roles
ansible-playbook image-build.yml
```

You should now see the `arcus-openhpc` image registered in glance.
