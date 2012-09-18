#
# Cookbook Name:: eos
# Recipe:: default
#
# Copyright 2012, Opscode, Inc.
#

# Install helper scripts for ohai and setting switch configuration

remote_directory node['eos']['scripts'] do
  owner 'root'
  group 'eosadmin'
  mode '0775'
  files_owner 'root'
  files_group 'eosadmin'
  files_mode '0775'
  recursive false
  purge true
end

