require 'spec_helper'
require 'ghost/hosts_file'

$hosts_file   = File.expand_path(File.join(File.dirname(__FILE__), "etc_hosts"))

describe Ghost::HostsFile do  
  before(:all) do
    class Ghost::HostsFile
      @@hosts_file = $hosts_file
    end
  end
  before(:each) { `touch #{$hosts_file.inspect}` }
  after  { `rm -f #{$hosts_file.inspect}` }
  
  it_behaves_like "a Ghost host"
  
  it "has an IP" do
    hostname = 'ghost-test-hostname.local'

    Ghost::HostsFile.add(hostname)
    host = Ghost::HostsFile.list.first
    host.ip.should eql('127.0.0.1')

    Ghost::HostsFile.empty!

    ip = '169.254.23.121'
    host = Ghost::HostsFile.add(hostname, ip)
    host.ip.should eql(ip)
  end

  it "has a hostname" do
    hostname = 'ghost-test-hostname.local'

    Ghost::HostsFile.add(hostname)
    host = Ghost::HostsFile.list.first
    host.hostname.should eql(hostname)

    Ghost::HostsFile.empty!

    ip = '169.254.23.121'
    Ghost::HostsFile.add(hostname, ip)
    host.hostname.should eql(hostname)
  end
  
  describe ".list" do
    it "returns an array" do
      Ghost::HostsFile.list.should be_instance_of(Array)
    end

    it "contains instances of Ghost::HostsFile" do
      Ghost::HostsFile.add('ghost-test-hostname.local')
      Ghost::HostsFile.list.first.should be_instance_of(Ghost::HostsFile)
    end
    
    it "gets all hosts on a single /etc/hosts line" do
      example = "127.0.0.1\tproject_a.local\t\t\tproject_b.local   project_c.local"
      File.open($hosts_file, 'w') {|f| f << example}
      hosts = Ghost::HostsFile.list
      hosts.should have(3).items
      hosts.map{|h|h.ip}.uniq.should eql(['127.0.0.1'])
      hosts.map{|h|h.host}.sort.should eql(%w[project_a.local project_b.local project_c.local])
      Ghost::HostsFile.add("project_d.local")
      Ghost::HostsFile.list.should have(4).items
    end
  end
  
  describe "#to_s" do
    it "returns hostname" do
      hostname = 'ghost-test-hostname.local'

      Ghost::HostsFile.add(hostname)
      host = Ghost::HostsFile.list.first
      host.to_s.should eql(hostname)
    end
  end

  describe "finder methods" do
    before do
      Ghost::HostsFile.add('abc.local')
      Ghost::HostsFile.add('def.local')
      Ghost::HostsFile.add('efg.local', '10.2.2.4')
    end

    it "returns valid Ghost::HostsFile when searching for host name" do
      Ghost::HostsFile.find_by_host('abc.local').should be_instance_of(Ghost::HostsFile)
    end
  end

  describe ".add" do
    it "returns Ghost::HostsFile object when passed hostname" do
      Ghost::HostsFile.add('ghost-test-hostname.local').should be_instance_of(Ghost::HostsFile)
    end

    it "returns Ghost::HostsFile object when passed hostname" do
      Ghost::HostsFile.add('ghost-test-hostname.local', '10.0.0.2').should be_instance_of(Ghost::HostsFile)
    end

    it "raises error if hostname already exists and not add a duplicate" do
      Ghost::HostsFile.empty!
      Ghost::HostsFile.add('ghost-test-hostname.local')
      lambda { Ghost::HostsFile.add('ghost-test-hostname.local') }.should raise_error
      Ghost::HostsFile.list.should have(1).thing
    end

    it "overwrites existing hostname if forced" do
      hostname = 'ghost-test-hostname.local'

      Ghost::HostsFile.empty!
      Ghost::HostsFile.add(hostname)

      Ghost::HostsFile.list.first.hostname.should eql(hostname)
      Ghost::HostsFile.list.first.ip.should eql('127.0.0.1')

      Ghost::HostsFile.add(hostname, '10.0.0.1', true)
      Ghost::HostsFile.list.first.hostname.should eql(hostname)
      Ghost::HostsFile.list.first.ip.should eql('10.0.0.1')

      Ghost::HostsFile.list.should have(1).thing
    end

    it "should raise SocketError if it can't find hostname's ip" do
      Ghost::HostsFile.empty!
      lambda { Ghost::HostsFile.add('ghost-test-alias-hostname.google', 'google') }.should raise_error(SocketError)
    end
  end

  describe ".empty!" do
    it "empties the hostnames" do
      Ghost::HostsFile.add('ghost-test-hostname.local') # add a hostname to be sure
      Ghost::HostsFile.empty!
      Ghost::HostsFile.list.should have(0).things
    end
  end

  describe ".delete_matching" do
    it "deletes matching hostnames" do
      keep = 'ghost-test-hostname-keep.local'
      Ghost::HostsFile.add(keep)
      Ghost::HostsFile.add('ghost-test-hostname-match1.local')
      Ghost::HostsFile.add('ghost-test-hostname-match2.local')
      Ghost::HostsFile.delete_matching('match')
      Ghost::HostsFile.list.should have(1).thing
      Ghost::HostsFile.list.first.hostname.should eql(keep)
    end
  end
  
end
