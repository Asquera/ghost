begin
  gem 'rspec', '2.6.0'
  require 'rspec'
rescue LoadError => e
  puts e.inspect
  require 'rubygems'
  
  require 'rspec'
end
begin
  require 'rspec/core/rake_task'
rescue LoadError => e
  puts e.inspect
  puts <<-EOS
To use rspec for testing you must install rspec gem:
    gem install rspec
EOS
  exit(0)
end