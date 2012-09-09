Installing and Configuring Chef on Arista vEOS
==============

Introduction
-------------
This note describes how to configure a vEOS virtual machine to
run chef-client.

Prerequisites
-------------
# You need a vEOS Image for VMware Fusion.  Ask Kevin or James if you
  don't have it already.
# VMware Fusion installed
  You will need to know the IP subnet used for the `vmnet8` interface.
  You can either use `ifconfig` or consult the vmware `dhcpd.conf` at
  `/Library/Preferences/VMware Fusion/vmnet8/dhcpd.conf`

Configuration Information
-------------------------
You will need the following information given the IP subnet above.  In
this example we consider the subnet is 192.168.181.0/24.

# The IP of your laptop is `<SUBNET>.1` i.e `192.168.181.1`
# The IP of the vmware route is `<SUBNET>.2` i.e. `192.168.181.2`.  This
  also hosts a ntp server.
# You should pick an IP address not allocated by DHCP on `vmnet8`.  The
  default is to use .128->.254 for DHCP, so for instance .101 is a good
address i.e. `192.168.181.101`.

The vEOS image installs a switch configured with a management
interface(`ma1`) and 4 ethernet interfaces (`et1-4`).

Installing
----------
### Initial bootstrap

To initially bootstrap the switch you need setup IP networking for the
management interface so you can then download whatever else is needed
from external sources.

Login in console as `admin` with no password

### Setup ip adress and routing

> en
# config
# hostname switch002
# interface ma1
# ip address 192.168.181.101/24
# ip host 192.168.181.101
# end
# ip route 0.0.0.0/0 192.168.181.2
# end

### set clock and ntp

# config
# clock timezone PST
# ntp server 0.north-america.pool.ntp.org prefer
# ntp server 1.north-america.pool.ntp.org
# ntp server 2.north-america.pool.ntp.org
# end
# bash sudo hwclock --localtime  -s

### Installing chef-client package

# copy http://opscode-omnitruck-release.s3.amazonaws.com/el/6/i686/chef-10.14.0-1.el6.i686.rpm extension:
# extension chef-10.14.0-1.el6.i686.rpm
# copy installed-extensions boot-extensions

### Enable scheduled chef-client run
# config
# schedule chef-client interval 5 max-log-files 20 command bash sudo /usr/bin/chef-client -c /persist/local/chef/client.rb
# end
#

### configure chef-client

    #bash
    Arista Networks EOS shell
    [admin@switch002 ~]$ sudo -s
    bash-4.1# scp james@192.168.181.1:~/Downloads/jc_arista-validator.pem /persist/local/chef
    bash-4.1# cd /persist/local/
    bash-4.1# mkdir chef
    bash-4.1# cat > chef/client.rb
    hostname = `hostname -s`.chomp
    orgname="jc_arista"
    current_dir = File.dirname(__FILE__)

    log_level                :info
    log_location             STDOUT
    node_name                hostname
    client_key               "#{current_dir}/#{hostname}.pem"
    validation_client_name   "#{orgname}-validator"
    validation_key           "#{current_dir}/#{orgname}-validator.pem"
    chef_server_url "https://api.opscode.com/organizations/#{orgname}"
    ^C

### Reload and check chef

    # reload
    .... wait for reboot
    # show extensions
    # bash
    Arista Networks EOS shell
    [admin@switch002 ~]$ sudo -s
    bash-4.1# chef-client -c /persist/local/chef/client.rb

