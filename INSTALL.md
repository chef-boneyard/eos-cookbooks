Installing and Configuring Chef on Arista vEOS
==============

Introduction
-------------
This note describes how to configure a vEOS virtual machine to
run chef-client.

Prerequisites
-------------
- You need a vEOS Image for VMware Fusion.
- VMware Fusion installed
  You will need to know the IP subnet used for the `vmnet8` interface.
  You can either use `ifconfig` when Fusion is running or consult the
  vmware `dhcpd.conf` at
  `/Library/Preferences/VMware Fusion/vmnet8/dhcpd.conf`

Configuration Information
-------------------------
You will need the following information given the IP subnet above.  In
this example we consider the subnet is 192.168.181.0/24.

1. The IP of your laptop is `<SUBNET>.1` i.e `192.168.181.1`
2. The IP of the vmware route is `<SUBNET>.2` i.e. `192.168.181.2`.  This
  also hosts a ntp server.
3. You should pick an IP address not allocated by DHCP on `vmnet8`.  The
  default is to use .128->.254 for DHCP, so for instance .101 is a good
address i.e. `192.168.181.101`.

The vEOS image installs a switch configured with a management
interface(`ma1`) and 4 ethernet interfaces (`et1-4`).

EOS 101 for Chef admins
-----------------------
- EOS is based on Fedora Core 14.  Our EL6 packages work on it just
  fine.
- vEOS reports that it runs a x86_86 kernel, but the userland
  consists of i686 packages.  tl;dr Install an i686 version of
  chef onto it
- EOS provides a default shell (`/usr/bin/Cli`) which looks similar
  to Cisco IOS.  This is what you get dropped into via ssh so
  unfortuanely scp won't work.
- The default installed user/password is `admin` with no password.  In
  order to login via SSH you'll need to setup a password for the admin
  user.
- To get to the useful commands you have to `enable` them by entering
  `enable`.
- The commands can be abbreviated (`enable` -> `en`, `show` -> `sh`,
  ...)
- Hitting `?` at any point in a command will bring up context sensitive
  help
- you can drop into a bash shell by the `bash` command from `Cli`.
- The bulk of the filesystem is on tmpfs.  If you need to store
  something across restarts, `/mnt/flash` is persistent.

For more info you can look at a [quick start guide](http://www.aristanetworks.com/docs/Manuals/QS_Modular_BW.pdf) which covers how to get IP networking up and running and setting up login via ssh on the switch or the [full EOS manual](http://www.aristanetworks.com/docs/Manuals/EOS-4.9.5-SysMsgGuide.pdf)

Installing
----------
### Initial bootstrap

To initially bootstrap the switch you need setup IP networking for the
management interface so you can then download whatever else is needed
from external sources.

Login in on the vmware console as `admin` with no password and follow the
steps below:

### Setup ip adress and routing

NOTE: Replace `192.168.181.` with whatever subnet `vmnet8` is on for
your local environment

From `Cli`:

    > en
    # config
    # interface ma1
    # ip address 192.168.181.101/24
    # ip host 192.168.181.101
    # end
    # ip name-server 192.168.181.2
    # ip route 0.0.0.0/0 192.168.181.2
    # end

You should now have basic networking running, including DNS.  You should
now be able to do things such as ping/ssh/wget an external host.

### Load a more complete startup-config (optional but recommended)
In the `eos-cookbooks` project there is a Rake task `startup-config`
which generates a more complete startup config with NTP config and some
other useful pieces.  It is configured with an `admin` user with the
password `password` so that after loading it you can login in via ssh
directly.

    [eos-cookbooks]$ rake
    Using hostname : switch001
    Using IP Address for switch : 192.168.181.101

    Generate config file 'startup-config-101'

You can supply a hostname and IP address different from the defaults:

    [eos-cookbooks]$ rake startup-config[myswitch103,103]
    Using hostname : myswitch103
    Using IP Address for switch : 192.168.181.103

    Generate config file 'startup-config-103'

To upload, from the EOS Cli, assuming your checkout of this repo is in
~/eos-cookbooks

    # scp USERNAME@192.168.181.1:~/eos-cookbooks/startup-config-101 startup-config
    # copy startup-config running-config

You should now be running the configuration you just uploaded.

### Installing chef-client package

    # copy http://opscode-omnitruck-release.s3.amazonaws.com/el/6/i686/chef-10.16.0-1.el6.i686.rpm extension:
    # extension chef-10.16.0-1.el6.i686.rpm
    # copy installed-extensions boot-extensions

### Enable scheduled chef-client run
We use the scheduled jobs feature of EOS to run chef-client.  Logs will
be put into `/mnt/flash/scheduled/chef-client`.

    # config
    # schedule chef-client interval 5 max-log-files 20 command bash sudo /usr/bin/chef-client -c /persist/local/chef/client.rb
    # end

### configure chef-client

You need to upload a `client.rb` for the chef server (This example uses hosted
chef with a orgname of 'arista_demo') and the validator cert.

    # scp USERNAME@192.168.181.1:~/Downloads/arista_demo-validator.pem /persist/local/chef
    # bash sudo -s mkdir -p /persist/local/chef

    # bash
    # sudo -s
    bash-4.1# cat > chef/client.rb
    hostname = `hostname -s`.chomp
    orgname="arista_demo"
    current_dir = File.dirname(__FILE__)

    log_level                :info
    log_location             STDOUT
    verbose_logging          false
    enable_reporting         false
    node_name                hostname
    client_key               "#{current_dir}/#{hostname}.pem"
    validation_client_name   "#{orgname}-validator"
    validation_key           "#{current_dir}/#{orgname}-validator.pem"
    chef_server_url          "https://api.opscode.com/organizations/#{orgname}"
    ^C

### Reload and check chef

    # reload
    .... wait for reboot
    # show extensions
    # bash
    Arista Networks EOS shell
    [admin@switch002 ~]$ sudo -s
    bash-4.1# chef-client -c /persist/local/chef/client.rb

