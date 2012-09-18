

action :enable do
  args = if new_resource.description
             "--description \"#{new_resource.description}\""
         else
             ""
         end
  execute "#{node['eos']['scripts']}/interface.py --set -i #{new_resource.name} --enable #{args}"
end

action :disable do
  args = if new_resource.description
             "--description \"#{new_resource.description}\""
         else
             ""
         end
  execute "#{node['eos']['scripts']}/interface.py --set -i #{new_resource.name} --disable #{args}"
end
