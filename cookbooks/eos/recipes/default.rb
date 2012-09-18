#
# Cookbook Name:: eos
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Install helper scripts for ohai and setting switch configuration

remote_directory "/mnt/flash/scripts" do
  owner 'root'
  group 'eosadmin'
  mode '0755'
  recursive false
  purge true
end

