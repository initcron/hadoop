# Copyright 2011, Outbrain, Inc.
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


include_recipe "java"

#creating the hadoop username
user "#{node["hadoop"]["username"]}" do
  comment "Hadoop User"
  home "/home/#{node["hadoop"]["username"]}"
  shell "/bin/bash"
#  password "#{node["hadoop"]["password"]}"
  action :create
end

group "#{node["hadoop"]["group"]}" do
#  gid 999
  members ['hadoop']
  action :create
end

#creating the hadoop home directory
directory "/home/#{node["hadoop"]["username"]}" do
  owner node["hadoop"]["username"]
  group node["hadoop"]["group"]
  mode "0755"
  action :create
end

directory "/mnt/tmp" do
  owner node["hadoop"]["username"]
  group node["hadoop"]["group"]
  mode "0755"
  action :create
  not_if "test -d /mnt/tmp"
end

directory "/data" do
  owner node["hadoop"]["username"]
  group node["hadoop"]["group"]
  mode "0755"
  action :create
  not_if "test -d /data"
end

### Run this only if  ec2 instance
#if node.attribute?("ec2")
#  include_recipe "aws"
#  #include_recipe "xfs"
#  aws = data_bag_item("aws", "main")
#
#  aws_ebs_volume "ebs_volume" do
#    aws_access_key aws['aws_access_key_id']
#    aws_secret_access_key aws['aws_secret_access_key']
#    size  node["ebs"]["size"]
#    device node["ebs"]["dev"]
#    action [ :create, :attach ]
#  end

#  package "xfsprogs" do
#    action :install
#  end

#  script "xfs_format_volume" do
#    interpreter "bash"
##    not_if "xfs_admin -u #{node["ebs"]["dev-ec2"]} > /dev/null 2>&1"
#    not_if "file -sL #{node["ebs"]["dev-ec2"]} | grep -i ext3 > /dev/null 2>&1"
#    user "root"
#    cwd "/"
#    code <<-EOH
#    mkfs.ext3 #{node["ebs"]["dev-ec2"]}
#  EOH
#  end

#  mount "/data" do
#    device node["ebs"]["dev-ec2"]
#    fstype "ext3"
#    options "defaults"
#    action [:mount, :enable]
#  end
#end

directory "/data/logs" do
  owner node["hadoop"]["username"]
  group node["hadoop"]["group"]
  mode "0755"
  recursive true
  action :create
end

directory "/data/tmp" do
  owner node["hadoop"]["username"]
  group node["hadoop"]["group"]
  mode "0755"
  recursive true
  action :create
end
#################
#   ZooKeeper   #
#################

if node.role?("zookeeper")
  # By default, let's set zkConnect to this zk node. This covers the case
  # where only one machine is running ZooKeeper and is running other services as well
  node.normal["default"]["zkConnect"] = "#{node[:fqdn]}:2181"
  node.normal["kafka"]["zkConnect"] = "#{node["default"]["zkConnect"]}/#{node["kafka"]["zkChroot"]}"
  #node.normal["kafka"]["zkConnect"] = "#{node["default"]["zkConnect"]}"
   node.normal["hbase"]["zkConnect"]= "#{node["default"]["zkConnect"]}"
end

if !node.chef.solo
zookeeper = search(:node, "chef_environment:#{node.chef_environment} AND role:zookeeper")
if !zookeeper[0].nil?
  # We have an existing ZooKeeper cluster, override the single-node values
  node.normal["zookeeper"]["host"] = "#{zookeeper[0][:fqdn]}"
  zookeeperip=zookeeper.collect { |i| "#{i[:fqdn]}" }
  zkconnectstr=zookeeperip.collect { |i| i.to_s + ":#{node["zookeeper"]["client_port"]}" }.each { |i| puts i }.join(",")
  zkhosts=zookeeperip.collect { |i| i.to_s }.each { |i| puts i }.join(",")
  node.normal["default"]["zkConnect"]=zkconnectstr
  node.normal["default"]["zkHosts"]=zkhosts
  node.normal["kafka"]["zkConnect"] = "#{node["default"]["zkConnect"]}/#{node["kafka"]["zkChroot"]}"
  #node.normal["kafka"]["zkConnect"] = "#{node["default"]["zkConnect"]}"
end
end

