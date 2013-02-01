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

package "wget" do
  action :install
end

case "#{node.install.type}"
when "remote"
  script "download_hadoop" do
    interpreter "bash"
    not_if "test -f /opt/#{node["hadoop"]["archive-name"]}"
    user "root"
    cwd "/opt"
    code <<-EOH
  wget --output-document=/opt/#{node["hadoop"]["archive-name"]} #{node["hadoop"]["download-url"]}
  EOH
  end
when "local"
  cookbook_file "/opt/#{node["hadoop"]["archive-name"]}" do
    source "artifacts/#{node["hadoop"]["archive-name"]}" 
    mode "0644"
    action :create_if_missing
  end
end

script "extract_hadoop" do
  interpreter "bash"
  not_if "test -d /opt/#{node["hadoop"]["folder-name"]}"
  user "root"
  cwd "/opt"
  code <<-EOH
tar -zxf #{node["hadoop"]["archive-name"]}
chown -R #{node["hadoop"]["username"]} #{node["hadoop"]["folder-name"]}
chgrp -R #{node["hadoop"]["group"]} #{node["hadoop"]["folder-name"]}
EOH
end

case "#{node.install.type}"
when "remote"
  script "download_hbase" do
    interpreter "bash"
    not_if "test -f /opt/#{node["hbase"]["archive-name"]}"
    user "root"
    cwd "/opt"
    code <<-EOH
  wget -O /opt/#{node["hbase"]["archive-name"]} #{node["hbase"]["download-url"]}
  EOH
  end
when "local"
  cookbook_file "/opt/#{node["hbase"]["archive-name"]}" do
    source "artifacts/#{node["hbase"]["archive-name"]}"
    mode "0644"
    action :create_if_missing
  end
end

script "extract_hbase" do
  interpreter "bash"
  not_if "test -d /opt/#{node["hbase"]["folder-name"]}/conf"
  user "root"
  cwd "/opt"
  code <<-EOH
tar -zxf #{node["hbase"]["archive-name"]}
chown -R #{node["hadoop"]["username"]}:#{node["hadoop"]["username"]} #{node["hbase"]["folder-name"]}
rm -rf #{node["hbase"]["folder-name"]}/lib/hadoop-core-* # Remove Hadoop Core lib, need the one in HADOOP_HOME
EOH
end

script "update_env_vars_hbase" do
  interpreter "bash"
  user "root"
  code <<-EOH
sed -i '/hbase/d' /etc/environment
echo "export HBASE_HOME=/opt/#{node["hbase"]["folder-name"]}" >> /etc/environment
echo "export HBASE_CONF_DIR=/opt/#{node["hbase"]["folder-name"]}/conf" >> /etc/environment
echo "export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:/opt/#{node["hbase"]["folder-name"]}/lib/zookeeper-*.jar:\
/opt/#{node["hbase"]["folder-name"]}/hbase-#{node["hbase"]["version"]}.jar" >> /etc/environment
EOH
  not_if "grep HBASE_HOME=/opt/#{node["hbase"]["folder-name"]} /etc/environment"
end

script "update_env_vars_hadoop" do
  interpreter "bash"
  user "root"
  code <<-EOH
sed -i '/HADOOP_HOME/d' /etc/environment
echo "export HADOOP_HOME=/opt/#{node["hadoop"]["folder-name"]}" >> /etc/environment
EOH
  not_if "grep HADOOP_HOME=/opt/#{node["hadoop"]["folder-name"]} /etc/environment"
end


# Drop the Hadoop configuration on the target host.  Even if we don't install
# Hadoop daemons clients that need the libraries and config can just get this
# recipe.

#Look for IP address of the namenode by searching role:namenode
#This can be overridden by role override_attributes
if !node.chef.solo
namenode = search(:node, "chef_environment:#{node.chef_environment} AND role:hadoop_namenode")
if !namenode[0].nil?
node.normal["Hadoop"]["Master"] = "#{namenode[0][:fqdn]}"
end
end

if node.role?("hadoop_namenode")
  node.normal["Hadoop"]["Master"] = "#{node[:fqdn]}"
end

if !node.chef.solo
secondarynamenode = search(:node, "chef_environment:#{node.chef_environment} AND role:hadoop_secondarynamenode")
if !secondarynamenode[0].nil?
  node.normal["Hadoop"]["HDFS"]["dfsSecondaryHttpAddress"] = "#{secondarynamenode[0][:fqdn]}:50090"
end
end

if node.role?("hadoop_secondarynamenode")
  node.normal["Hadoop"]["HDFS"]["dfsSecondaryHttpAddress"] = "#{node[:fqdn]}:50090"
end

if !node.chef.solo
jobtracker  = search(:node, "chef_environment:#{node.chef_environment} AND role:hadoop_jobtracker")
if !jobtracker[0].nil?
node.normal["Hadoop"]["Jobtracker"]["Host"] = "#{jobtracker[0][:fqdn]}"
end
end

if node.role?("hadoop_jobtracker")
  node.normal["Hadoop"]["Jobtracker"]["Host"] = "#{node[:fqdn]}"
end

if !node.chef.solo
oozie = search(:node, "chef_environment:#{node.chef_environment} AND role:oozie")
if !oozie[0].nil?
node.normal["Hadoop"]["Core"]["hadoopProxyuserOozieHosts"] = "#{oozie[0][:fqdn]}"
end
end 

if node.role?("oozie")
  node.normal["Hadoop"]["Core"]["hadoopProxyuserOozieHosts"] = "#{node[:fqdn]}"
end

template "/opt/#{node["hadoop"]["folder-name"]}/conf/core-site.xml" do
  owner "#{node["hadoop"]["username"]}"
  group "#{node["hadoop"]["group"]}"
  mode "0644"
  source "core-site.xml.erb"
  #notifies :restart, resources(:service => "namenode")
  #notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

#template "/opt/#{node["hadoop"]["folder-name"]/conf/hdfs-site.xml" do
#  owner "root"
#  group "hadoop"
#  mode "0644"
#  source "hdfs-site.xml.erb"
#  #notifies :restart, resources(:service => "hadoop-0.20-datanode")
#end

template "/opt/#{node["hadoop"]["folder-name"]}/conf/mapred-site.xml" do
  owner "#{node["hadoop"]["username"]}"
  group "#{node["hadoop"]["group"]}"
  mode "0644"
  source "mapred-site.xml.erb"
  #notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

template "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-env.sh" do
  owner "#{node["hadoop"]["username"]}"
  group "#{node["hadoop"]["group"]}"
  mode "0644"
  source "hadoop-env.sh.erb"
  #notifies :restart, resources(:service => "hadoop-0.20-datanode")
  #notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

template "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-metrics.properties" do
  owner "#{node["hadoop"]["username"]}"
  group "#{node["hadoop"]["group"]}"
  mode "0644"
  source "hadoop-metrics.properties.erb"
end

template "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-site.xml" do
  owner "#{node["hadoop"]["username"]}"
  group "#{node["hadoop"]["group"]}"
  mode "0644"
  source "hbase-site.xml.erb"
  #notifies :restart, resources(:service => "hadoop-0.20-datanode")
  #notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

template "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-env.sh" do
  owner "#{node["hadoop"]["username"]}"
  group "#{node["hadoop"]["group"]}"
  mode "0644"
  source "hbase-env.sh.erb"
end

template "/opt/#{node["hadoop"]["folder-name"]}/conf/hdfs-site.xml" do
  owner "#{node["hadoop"]["username"]}"
  group "#{node["hadoop"]["group"]}"
  mode "0644"
  source "hdfs-site.xml.erb"
end

