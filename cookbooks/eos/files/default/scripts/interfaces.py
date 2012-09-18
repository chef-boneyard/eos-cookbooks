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
interfaces = sysdb['interface']['config']['eth']['phy']
interface_names = list(interfaces)

# Dump out the interfaces
def dump(if_list):
    all = dict()
    for interface in if_list:
	all[interface] = get(interface)
    print json.dumps(all, indent=4, sort_keys=True)

#
# Get a list of values for an interface
def get(interface):
    INTERFACE_KEYS = ['enabled', 'description'] 
    ret = dict()
    for k in INTERFACE_KEYS:
      ret[k] = getattr(interfaces[interface], k)
    return ret

def set(interface, enabled, description):
    if enabled: 
        interfaces[interface].enabled = enabled
    if description: 
        interfaces[interface].description = description


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
            dump([args.interface]) 
        else:
            print >> sys.stderr,  "ERROR: No such interface %s"%args.interface
            sys.exit(1)
    else: 
        dump(interface_names)
elif args.set:
    if not args.interface : parser.print_help()

    if args.interface in interface_names: 
    	set(args.interface, args.enable, args.description)
    else:
        print >> sys.stderr,  "ERROR: No such interface %s"%args.interface
        sys.exit(1)
else:
    parser.print_help()
