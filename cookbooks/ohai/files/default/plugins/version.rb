#
# Cookbook Name:: ohai
# Plugin:: version
#
# Copyright 2012, Xu Chen, AT&T
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

provides "arista"

begin
  cmd = "ip netns"
  
  has_default = nil
  begin
    status, stdout, stderr = run_command(:command => cmd)
    stdout.each_line do |line|
      if line.chomp == "default"
        has_default = true
      end
    end
  rescue
    Chef::Log.warn "error executing ip netns, executing without namespace setting"
  end
  
  if has_default
    cmd = "ip netns exec default /usr/bin/FastCli -p 15 -c \"show version\""
  else
    cmd = "/usr/bin/FastCli -p 15 -c \"show version\""
  end

  status, stdout, stderr = run_command(:command => cmd)
  
  arista Mash.new
  
  stdout.each_line do |line| 
    case line
    when /^Arista\s(\S+)/; arista[:model] = $1
    when /^Hardware\sversion\:\s+(\S+)/; arista[:hardware_version] = $1
    when /^Serial\snumber\:\s+(\S+)/; arista[:serial_number] = $1
    when /^System\sMAC\saddress\:\s+(\S+)/; arista[:mac_address] = $1
    when /^Software\simage\sversion\:\s+(\S+)/; arista[:software_image_version] = $1
    when /^Architecture\:\s+(\S+)/; arista[:architecture] = $1
    when /^Internal\sbuild\sversion\:\s+(\S+)/; arista[:internal_build_version] = $1
    when /^Internal\sbuild\sid\:\s+(\S+)/; arista[:internal_build_id] = $1
    end
  end
rescue => e
  Chef::Log.warn "Ohai arista version plugin failed with: '#{e}'"
end
