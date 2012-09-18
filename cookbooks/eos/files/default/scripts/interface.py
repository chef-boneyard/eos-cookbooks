#!/usr/bin/env python
#
# Dump out the interface definitions for consumption

import sys
import argparse
import json

import PyClient

#
# spin up Sysdb configuration
#
pc = PyClient.PyClient( "ar", "Sysdb" )
sysdb = pc.agentRoot()
interface_names = list(sysdb['interface']['config']['all'])

def get(interface):
    if interface.startswith("Vlan"):
        return get_vlan(interface)
    else:
        return get_phy(interface)

def set(interface, enabled, description):
    if enabled != None: 
        config(interface).enabled = enabled
    if description != None: 
        config(interface).description = description

def as_json(if_list):
    all = dict()
    for interface in if_list:
        all[interface] = get(interface)
    print json.dumps(all, indent=4, sort_keys=True)


def get_phy(interface):
    STATUS_KEYS = ['addr', 'speed', 'duplex', 'mtu'] 
    CONFIG_KEYS = ['enabled', 'description'] 
    ret = dict()
    for k in STATUS_KEYS:
        ret[k] = getattr(status(interface), k)

    for k in CONFIG_KEYS:
        ret[k] = getattr(config(interface), k)
    return ret

#
# Get a list of values for an vlan interface
def get_vlan(interface):
    CONFIG_KEYS = ['enabled', 'description'] 
    ret = dict()
    for k in CONFIG_KEYS:
        ret[k] = getattr(config(interface), k)
    return ret

def config(interface):
    if interface.startswith("Vlan"):
        return sysdb['interface']['config']['all'][interface]
    else:
        return sysdb['interface']['config']['eth']['phy'][interface]
 
def status(interface):
    return sysdb['interface']['status']['all'][interface]

parser = argparse.ArgumentParser(description='Show and set interface parameters.')
parser.add_argument('-i', '--interface', help='run against a single interface')

parser.add_argument('--get', action='store_true', help='get interface details')
parser.add_argument('--set', action='store_true', help='set interface details')

parser.add_argument('--enable', dest='enable', action='store_true', help='enable interface', default=None)
parser.add_argument('--disable', dest='enable', action='store_false', help='disable interface', default=None)
parser.add_argument('-d', '--description', help='Description of the interface')

args = parser.parse_args()
if args.get:
    if args.interface:
        if args.interface in interface_names:
            as_json([args.interface]) 
        else:
            print >> sys.stderr,  "ERROR: No such interface %s"%args.interface
            sys.exit(1)
    else: 
        as_json(interface_names)
elif args.set:
    if not args.interface : parser.print_help()

    if args.interface in interface_names: 
    	set(args.interface, args.enable, args.description)
    else:
        print >> sys.stderr,  "ERROR: No such interface %s"%args.interface
        sys.exit(1)
else:
    parser.print_help()
