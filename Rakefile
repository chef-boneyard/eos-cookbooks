require 'erb'
require 'rake/clean'
require 'fileutils'

ADDRESS="101"
HOSTNAME="switch001"

OUTPUT_FILE='startup-config'
TEMPLATE_FILE='config/startup-config.erb'

def get_template
  File.read(TEMPLATE_FILE)
end

def get_ipaddress(interface = "vmnet8")
  `ifconfig #{interface} |grep inet |cut -d' ' -f2`.strip
end

# return the start of the /24 for a given ip_address
def prefix(ip_address)
  ip_address.split(".")[0..-2].join(".")
end

desc "Builds the startup-config file, using ERB."
task "startup-config", [:hostname, :address] do  |t, args|
  local_ip = get_ipaddress()
  prefix = prefix(local_ip)
  hostname = if args.hostname.nil? then HOSTNAME else args.hostname end
  address = if args.address.nil? then ADDRESS else args.address end
  File.open("#{OUTPUT_FILE}-#{address}", "w+") do |f|
    template = ERB.new(get_template)
    vm_ip = "#{prefix}.#{address}"
    router_ip = "#{prefix}.2"
    puts "Using hostname : #{hostname}"
    puts "Using IP Address for switch : #{vm_ip}"
    b = binding
    f.write(template.result(b))
  end

  puts
  puts "Generate config file '#{OUTPUT_FILE}-#{address}'"
end

task :default => ["startup-config"]

CLEAN.include("#{OUTPUT_FILE}-*")
