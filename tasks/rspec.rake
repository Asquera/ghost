require File.dirname(__FILE__) + '/rake_helper'

desc "Run the specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--options', "spec/spec.opts"]
  #t.spec_files = FileList['spec/**/*_spec.rb']
  #t.libs << "test"
end
