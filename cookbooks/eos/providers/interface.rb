

action :enable do
  unless has_interface?(new_resource.name)
    Chef::Log.error("No such interface #{new_resource.name}")
  end

  unless enabled?(new_resource.name)
    args = if new_resource.description
             "--description \"#{new_resource.description}\""
           else
             ""
           end
    execute "Enable interface #{new_resource.name}" do
      command "#{node['eos']['scripts']}/interface.py --set -i #{new_resource.name} --enable #{args}"
    end
    new_resource.updated_by_last_action(true)
  end
end

action :disable do
  unless has_interface?(new_resource.name)
    Chef::Log.error("No such interface #{new_resource.name}")
  end
  if enabled?(new_resource.name)
    args = if new_resource.description
             "--description \"#{new_resource.description}\""
           else
             ""
           end
    execute "Disable interface #{new_resource.name}" do
      command "#{node['eos']['scripts']}/interface.py --set -i #{new_resource.name} --disable #{args}"
    end
    new_resource.updated_by_last_action(true)
  end
end

def has_interface?(interface)
  node.has_key?('sysdb') and node['sysdb'].has_key?('interface') and
    not node['sysdb']['interface'].nil? and
    node['sysdb']['interface'].has_key?(interface)
end

def enabled?(interface)
    has_interface?(interface) and
    node['sysdb']['interface'][interface].has_key?('enabled') and
    node['sysdb']['interface'][interface]['enabled']
end

