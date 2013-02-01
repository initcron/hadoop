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

include_recipe 'hadoop::default'

script "format_dfs" do
  interpreter "bash"
  not_if "test -d #{node["Hadoop"]["HDFS"]["dfsNameDir"][0]}/current"
#  user "#{node["hadoop"]["username"]}"
  user "root"
  cwd "/opt"
  code <<-EOH
source /etc/environment
/opt/#{node["hadoop"]["folder-name"]}/bin/hadoop namenode -format
EOH
end

node[:Hadoop][:HDFS][:dfsNameDir].each do |dir|
  script "dfs_name_dir_chown" do
    interpreter "bash"
    user "root"
    cwd "/opt"
    code <<-EOH
  source /etc/environment
  chown -R #{node["hadoop"]["username"]}:#{node["hadoop"]["group"]} #{dir}
  EOH
  end
end

ENV['USER'] = "#{node["hadoop"]["username"]}"

if platform?("redhat", "centos", "fedora")
  template "/etc/init.d/namenode" do
    source "namenode.init"
    owner "root"
    group "root"
    mode 0755
  end

  service "namenode" do
    service_name "namenode"
    pattern "namenode"
    start_command "/etc/init.d/namenode start"
    stop_command "/etc/init.d/namenode stop"
    status_command "ps auwwx | grep proc_namenode | grep -v grep"
    restart_command"/etc/init.d/namenode stop && sleep 10 && /etc/init.d/namenode start"
    action [ :enable, :start ]
    supports :start => true, :stop => true, :restart => true, :status => true, :reload => false
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/core-site.xml")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/mapred-site.xml")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-env.sh")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-metrics.properties")
    subscribes :restart, resources(:template => "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-site.xml")
  end
end

if platform?("ubuntu")
include_recipe "runit"
ENV['SVWAIT'] = "#{node["runit"]["svwait"]}"

runit_service "namenode" do
  action :start
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/core-site.xml")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/mapred-site.xml")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-env.sh")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-metrics.properties")
  subscribes :restart, resources(:template => "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-site.xml")
end
end
