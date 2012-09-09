
#
# Output of Cli 'show version' command
#

provides "eos"

require_plugin "eos"

begin
  cmd = "Cli -c \"show version\""
  status, stdout, stderr = run_command(:command => cmd)
  lines = stdout.split("\n")

  eos[:os_name] = lines.shift
  lines.each do |line|
    next if line.empty?

    k,v = line.split(':')
    if v.nil?
      Chef::Log.warn "Ohai eos version plugin - unparsable line 'line'"
    else
      k.downcase!
      k.gsub!(' ','_')
      eos[k] = v.strip
    end
  end
rescue => e
    Chef::Log.warn "Ohai eos version plugin failed with '#{e}'"
end
