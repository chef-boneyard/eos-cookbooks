

action :enable do
  if node['sysdb']['interface'][new_resource.name].nil?
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
  if node['sysdb']['interface'][new_resource.name].nil?
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

def enabled?(interface)
  node['sysdb']['interface'][interface]['enabled']
end
