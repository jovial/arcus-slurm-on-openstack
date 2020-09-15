#!/usr/bin/env python3

from __future__ import print_function
import csv
import sys, json, pprint
import openstack
import pprint

#from ClusterShell import NodeSet


def get_config():
    config = {}
    if len(sys.argv) == 1:
        # using from terraform
        config = json.load(sys.stdin)
        config["debug"] = False
    else:
        config = dict(
           zip(('os_cloud', 'rack_info_csv', 'prop'),
               sys.argv[1:]))
        config["debug"] = True
        pprint.pprint(config)
    return config


def get_rack_info(rack_info_file):
    rack_info = {}
    with open(rack_info_file) as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            rack_info[row["hardware_name"]] = {
                "instance_name": row["name"],
                "ip": row["ip"],
                "hardware_name": row["hardware_name"],
            }
    return rack_info


def get_hostnames(host_pattern):
    return list(NodeSet.NodeSet(host_pattern))


def find_baremetal_nodes(conn, rack_info):
    found = []

    hardware_names = list(rack_info.keys())
    nodes = conn.baremetal.nodes()
    for node in nodes:
        if node.name in hardware_names:
            node_info = rack_info[node.name]
            node_info["node_uuid"] = node["id"]
            node_info["instance_uuid"] = node["instance_id"]
            found.append(rack_info[node.name])

    missing_count = len(hardware_names) - len(found)
    if missing_count > 0:
        print(found)
        print(hardware_names)
        raise Exception(
            f"Unable to find all baremetal nodes: {missing_count}")

    return found


def print_result(nodes, prop_name):
    result = {}
    for node in nodes:
        result[node["hardware_name"]] = node[prop_name]
    print(json.dumps(result))


config = get_config()
rack_info = get_rack_info(config["rack_info_csv"])
conn = openstack.connection.from_config(cloud=config["os_cloud"])
found = find_baremetal_nodes(conn, rack_info)
print_result(found, config["prop"])
#print(json.dumps(found))
