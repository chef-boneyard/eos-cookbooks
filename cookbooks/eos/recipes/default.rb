#
# Cookbook Name:: eos
# Recipe:: default
#
# Copyright 2012, Opscode, Inc.
#

# Install helper scripts for ohai and setting switch configuration


directory node['eos']['scripts'] do
  owner 'root'
  group 'eosadmin'
  mode '0775'
  recursive false
end

template "#{node['eos']['scripts']}/interface.py" do
  action :create
  owner 'root'
  group 'eosadmin'
  mode '0755'
end
