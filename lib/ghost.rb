$: << File.dirname(__FILE__)

case RUBY_PLATFORM
when /darwin/
  require 'ghost/dscl'
  Ghost::Host.adapter = Ghost::Dscl
when /linux/
  require 'ghost/hosts_file'
  Ghost::Host.adapter = Ghost::HostsFile
end

require 'ghost/ssh_config'
