#
# Ohai plugin to grab info from Sysdb on an Arista switch
# running EOS
#

require "yajl"

provides "sysdb"

sysdb = Mash.new

# Interfaces
popen4("/persist/local/chef/scripts/interface.py --get") do |pid, stdin, stdout, stderr|
  stdin.close
  parser = Yajl::Parser.new
  sysdb['interface'] = parser.parse(stdout.read)
end

sysdb sysdb
