
provides "eos/installed_extensions"

require_plugin "eos"

eos[:installed_extensions] = Mash.new

begin
  cmd = "Cli -c \"show installed-extensions\""
  status, stdout, stderr = run_command(:command => cmd)
  eos[:installed_extensions] = stdout.split("\n")
rescue => e
  Chef::Log.warn "Ohai eos installed extensions plugin failed with '#{e}'"
end
