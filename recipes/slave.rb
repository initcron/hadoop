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

# Install the slave processes.

ENV['USER'] = "#{node["hadoop"]["username"]}"

directory "/data/dfs" do
  owner node["hadoop"]["username"]
  group node["hadoop"]["group"]
  mode "0755"
  recursive true
  action :create
end

node["Hadoop"]["HDFS"]["dfsDataDir"].each do |dir|
   directory dir do
      owner node["hadoop"]["username"]
      group node["hadoop"]["group"]
      mode "0755"
      recursive true
      action :create
   end
end

if platform?("ubuntu")
include_recipe "runit"
ENV['SVWAIT'] = "#{node["runit"]["svwait"]}"

runit_service "datanode" do
  action :start
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/core-site.xml")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/mapred-site.xml")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-env.sh")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-metrics.properties")
  subscribes :restart, resources(:template => "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-site.xml")
end

runit_service "tasktracker" do
  action :start
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/core-site.xml")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/mapred-site.xml")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-env.sh")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-metrics.properties")
  subscribes :restart, resources(:template => "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-site.xml")
end

runit_service "regionserver" do
  action :start
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/core-site.xml")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/mapred-site.xml")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-env.sh")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-metrics.properties")
  subscribes :restart, resources(:template => "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-site.xml")
  subscribes :restart, resources(:template => "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-env.sh")
end
end

if platform?("redhat", "centos", "fedora")

  template "/etc/init.d/datanode" do
    source "datanode.init"
    owner "root"
    group "root"
    mode 0755
  end

  template "/etc/init.d/tasktracker" do
    source "tasktracker.init"
    owner "root"
    group "root"
    mode 0755
  end

  template "/etc/init.d/regionserver" do
    source "regionserver.init"
    owner "root"
    group "root"
    mode 0755
  end

service "datanode" do
    service_name "datanode"
    pattern "org.apache.hadoop.hdfs.server.datanode.DataNode"
    start_command "/etc/init.d/datanode start"
    stop_command "/etc/init.d/datanode stop"
    status_command "ps auwwx | grep org.apache.hadoop.hdfs.server.datanode.DataNode | grep -v grep"
    restart_command"/etc/init.d/datanode stop && sleep 10 && /etc/init.d/datanode start"
    action [ :enable, :start ]
    supports :start => true, :stop => true, :restart => true, :status => true, :reload => false
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/core-site.xml")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/mapred-site.xml")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-env.sh")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-metrics.properties")
    subscribes :restart, resources(:template => "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-site.xml")
end

service "tasktracker" do
    service_name "tasktracker"
    pattern "org.apache.hadoop.mapred.TaskTracker"
    start_command "/etc/init.d/tasktracker start"
    stop_command "/etc/init.d/tasktracker stop"
    status_command "ps auwwx | grep org.apache.hadoop.mapred.TaskTracker | grep -v grep"
    restart_command"/etc/init.d/tasktracker stop && sleep 10 && /etc/init.d/tasktracker start"
    action [ :enable, :start ]
    supports :start => true, :stop => true, :restart => true, :status => true, :reload => false
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/core-site.xml")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/mapred-site.xml")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-env.sh")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-metrics.properties")
    subscribes :restart, resources(:template => "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-site.xml")
end

service "regionserver" do
  service_name "regionserver"
  pattern "regionserver"
    start_command "/etc/init.d/regionserver start"
    stop_command "/etc/init.d/regionserver stop"
    status_command "ps auwwx | grep regionserver | grep hbase |  grep -v grep"
    restart_command"/etc/init.d/regionserver stop && sleep 10 && /etc/init.d/regionserver start"
    action [ :enable, :start ]
    supports :start => true, :stop => true, :restart => true, :status => true, :reload => false
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/core-site.xml")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/mapred-site.xml")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-env.sh")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-metrics.properties")
    subscribes :restart, resources(:template => "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-site.xml")
    subscribes :restart, resources(:template => "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-env.sh")
end
end
