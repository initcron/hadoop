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


ENV['USER'] = "#{node["hadoop"]["username"]}"

if platform?("ubuntu")
include_recipe "runit"

runit_service "secondarynamenode" do
  action :start
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/core-site.xml")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/mapred-site.xml")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-env.sh")
  subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-metrics.properties")
  subscribes :restart, resources(:template => "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-site.xml")
end
end

if platform?("redhat", "centos", "fedora")
  template "/etc/init.d/secondarynamenode" do
    source "secondarynamenode.init"
    owner "root"
    group "root"
    mode 0755
  end

  service "secondarynamenode" do
    service_name "secondarynamenode"
    pattern "secondarynamenode"
    start_command "/etc/init.d/secondarynamenode start"
    stop_command "/etc/init.d/secondarynamenode stop"
    status_command "ps auwwx | grep secondarynamenode | grep -v grep"
    restart_command"/etc/init.d/secondarynamenode stop && sleep 4 && /etc/init.d/secondarynamenode start"
    action [ :enable, :start ]
    supports :start => true, :stop => true, :restart => true, :status => true, :reload => false
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/core-site.xml")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/mapred-site.xml")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-env.sh")
    subscribes :restart, resources(:template => "/opt/#{node["hadoop"]["folder-name"]}/conf/hadoop-metrics.properties")
    subscribes :restart, resources(:template => "/opt/#{node["hbase"]["folder-name"]}/conf/hbase-site.xml")
  end
end
