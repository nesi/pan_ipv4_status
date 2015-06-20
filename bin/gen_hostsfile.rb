#!/usr/local/bin/ruby
require_relative '../rlib/configuration.rb'
require 'pp'

# @param target_net [String] Network (name must be consistent with the rack_master.json hash)
# @param filename [String] write a list of hosts we want to ping into this file
def gen_hostsfile(target_net, filename=nil)
  c = Configuration.new("#{File.dirname(__FILE__)}/../www/rack_master.json")
  File.open(filename,"w") do |fd|
    c.rack.each do |k,v|
      v["nodes"].each do |k2,v2|
        fd.puts v2[target_net] if v2[target_net] != nil && v2[target_net] != ""
      end
    end
  end
end

gen_hostsfile('management_net', "#{File.dirname(__FILE__)}/../conf/hosts_management_net");
gen_hostsfile('provision_net', "#{File.dirname(__FILE__)}/../hosts_provisioning_net");
gen_hostsfile('ipoib_net', "#{File.dirname(__FILE__)}/../hosts_ipoib_net");


