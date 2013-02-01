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

include_recipe "hadoop::base"

directory "#{node["kafka"]["home"]}" do
  owner node["hadoop"]["username"]
  group node["hadoop"]["group"]
  mode "0755"
  action :create
end

directory "/data/kafka-logs" do
  owner node["hadoop"]["username"]
  group node["hadoop"]["group"]
  mode "0755"
  action :create
end

case "#{node.install.type}"
when "remote"
  remote_file "/opt/#{node["kafka"]["tarball"]}" do
    source "#{node["kafka"]["url"]}"
    mode 00644
    action :create_if_missing
end
when "local"
  cookbook_file "/opt/#{node["kafka"]["tarball"]}" do
    source "artifacts/#{node["kafka"]["tarball"]}"
    mode "0644"
    action :create_if_missing
  end
end

script "download_and_extract_kafka" do
  interpreter "bash"
  not_if "test -d #{node["kafka"]["home"]}/config"
  user node["hadoop"]["username"]
  user "root"
  cwd  "/opt"
  code <<-EOH
tar -xzf #{node["kafka"]["tarball"]}
#export PATH=#{node["java"]["java_home"]}:$PATH
#cd #{node["kafka"]["home"]} && ./sbt update && ./sbt package
chown -R #{node["hadoop"]["username"]} #{node["kafka"]["home"]}
chgrp -R #{node["hadoop"]["group"]} #{node["kafka"]["home"]}
EOH
end

script "create_zookeeper_chroot" do
  interpreter "bash"
  user "root"
  cwd "#{node["kafka"]["home"]}"
  code <<-EOH
java -cp .:libs/* org.apache.zookeeper.ZooKeeperMain -server #{node["default"]["zkConnect"]} create /#{node["kafka"]["zkChroot"]} kafka
EOH
end

kafka_servers = [node]
if !node.chef.solo
  kafka_servers += search(:node, "role:kafka AND chef_environment:#{node.chef_environment} NOT name:#{node.name}") 
end 

kafka_servers.sort! { |a, b| a.name <=> b.name }
brokerid = kafka_servers.collect { |n| n[:ipaddress] }.index(node[:ipaddress])

template "#{node["kafka"]["home"]}/config/server.properties" do
  owner "#{node["hadoop"]["username"]}"
  group "#{node["hadoop"]["group"]}"
  mode "0644"
  source "server.properties.erb"
  variables(:brokerid => brokerid)
  #notifies :restart, "runit_service[kafka]"
end

template "#{node["kafka"]["home"]}/config/log4j.properties" do
  owner "#{node["hadoop"]["username"]}"
  group "#{node["hadoop"]["group"]}"
  mode "0644"
  source "kafka-log4j.properties.erb"
end

if platform?("ubuntu")
include_recipe "runit"
ENV['SVWAIT'] = "#{node["runit"]["svwait"]}"

runit_service "kafka" do 
#  owner "#{node["hadoop"]["username"]}"
#  group "#{node["hadoop"]["group"]}"
#  start_command = "#{node["kafka"]["home"]}/bin/kafka-server-start.sh #{node["kafka"]["home"]}/config/server.properties"
#  stop_command  = "#{node["kafka"]["home"]}/bin/kafka-server-stop.sh"
#  restart_command = "#{node["kafka"]["home"]}/bin/kafka-server-stop.sh"
#  supports :start => true, :stop => true, :restart => true
   action :start
   subscribes :restart, resources(:template => "#{node["kafka"]["home"]}/config/server.properties")
end
end

if platform?("redhat", "centos", "fedora")
  template "/etc/init.d/kafka" do
    source "kafka.init"
    owner "root"
    group "root"
    mode 0755
  end

  service "kafka" do
    service_name "kafka"
    pattern "kafka.Kafka"
    start_command "/etc/init.d/kafka start"
    stop_command "/etc/init.d/kafka stop"
    status_command "ps auwwx | grep kafka | grep -v grep"
    restart_command"/etc/init.d/kafka stop && sleep 4 && /etc/init.d/kafka start"
    action [ :enable, :start ]
    supports :start => true, :stop => true, :restart => true, :status => true, :reload => false
    subscribes :restart, resources(:template => "#{node["kafka"]["home"]}/config/server.properties")
  end
end


