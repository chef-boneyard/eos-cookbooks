

# Ensure the chef embedded tools dir is first in our PATH
# to pick up gem, ruby, ...
file "/etc/profile.d/omnibus-embedded.sh" do
  content "export PATH=\"$PATH:/opt/chef/embedded/bin\""
  action :create
end
