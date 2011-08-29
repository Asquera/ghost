require 'spec_helper'
require 'ghost'

# Warning: these tests will delete all hostnames in the system. Please back them up first

shared_examples "a Ghost host" do
  describe described_class, ".list" do
    after(:each) { described_class.empty! }
    
    it "should return an array" do
      described_class.list.should be_instance_of(Array)
    end
    
    it "should contain instances of described_class" do
      described_class.add('ghost-test-hostname.local')
      described_class.list.first.should be_instance_of(described_class)
    end
  end
  
  describe described_class do
    after(:each) { described_class.empty! }
    
    it "should have an IP" do
      hostname = 'ghost-test-hostname.local'
      
      described_class.add(hostname)
      host = described_class.list.first
      host.ip.should eql('127.0.0.1')
      
      described_class.empty!
      
      ip = '169.254.23.121'
      host = described_class.add(hostname, ip)
      host.ip.should eql(ip)
    end
    
    it "should have a hostname" do
      hostname = 'ghost-test-hostname.local'
      
      described_class.add(hostname)
      host = described_class.list.first
      host.hostname.should eql(hostname)
      
      described_class.empty!
      
      ip = '169.254.23.121'
      described_class.add(hostname, ip)
      host.hostname.should eql(hostname)
    end
    
    it ".to_s should return hostname" do
      hostname = 'ghost-test-hostname.local'
      
      described_class.add(hostname)
      host = described_class.list.first
      host.to_s.should eql(hostname)
    end
  end
  
  describe described_class, "finder methods" do
    after(:all) { described_class.empty! }
    before(:all) do
      described_class.empty!
      described_class.add('abc.local')
      described_class.add('def.local')
      described_class.add('efg.local', '10.2.2.4')
    end
    
    it "should return valid #{described_class} when searching for host name" do
      described_class.find_by_host('abc.local').should be_instance_of(described_class)
    end
    
  end
  
  describe described_class, ".add" do
    after(:each) { described_class.empty! }
    
    it "should return #{described_class} object when passed hostname" do
      described_class.add('ghost-test-hostname.local').should be_instance_of(described_class)
    end
    
    it "should return #{described_class} object when passed hostname" do
      described_class.add('ghost-test-hostname.local', '10.0.0.2').should be_instance_of(described_class)
    end
    
    it "should raise error if hostname already exists and not add a duplicate" do
      described_class.empty!
      described_class.add('ghost-test-hostname.local')
      lambda { described_class.add('ghost-test-hostname.local') }.should raise_error
      described_class.list.should have(1).thing
    end
    
    it "should overwrite existing hostname if forced" do
      hostname = 'ghost-test-hostname.local'
      
      described_class.empty!
      described_class.add(hostname)
      
      described_class.list.first.hostname.should eql(hostname)
      described_class.list.first.ip.should eql('127.0.0.1')
      
      described_class.add(hostname, '10.0.0.1', true)
      described_class.list.first.hostname.should eql(hostname)
      described_class.list.first.ip.should eql('10.0.0.1')
      
      described_class.list.should have(1).thing
    end
    
    it "should add a hostname using second hostname's ip" do
      hostname = 'localhost'
      alias_hostname = 'ghost-test-alias-hostname.local'
      
      described_class.empty!
      
      described_class.add(alias_hostname, hostname)
      
      described_class.list.last.ip.should eql("127.0.0.1")
    end
    
    it "should raise SocketError if it can't find hostname's ip" do
      described_class.empty!
      lambda { described_class.add('ghost-test-alias-hostname.google', 'google') }.should raise_error(SocketError)
    end
  end
  
  describe described_class, ".empty!" do
    it "should empty the hostnames" do
      described_class.add('ghost-test-hostname.local') # add a hostname to be sure
      described_class.empty!
      described_class.list.should have(0).things
    end
  end
  
  describe described_class, ".delete_matching" do
    it "should delete matching hostnames" do
      keep = 'ghost-test-hostname-keep.local'
      described_class.add(keep)
      described_class.add('ghost-test-hostname-match1.local')
      described_class.add('ghost-test-hostname-match2.local')
      described_class.delete_matching('match')
      described_class.list.should have(1).thing
      described_class.list.first.hostname.should eql(keep)
    end
  end
  
  
  describe described_class, ".backup and", described_class, ".restore" do
    it "should return a yaml file of all hosts and IPs when backing up"
    it "should empty the hosts and restore only the ones in given yaml"
  end
end
  