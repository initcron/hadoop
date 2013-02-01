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

#include_recipe "runit"
#runit_service "oozie"

package "unzip" do 
  action :install
end

package "zip" do
  action :install
end

case "#{node.install.type}"
when "remote"
  include_recipe "cloudy_s3"
  s3 = data_bag_item('s3', 'main')
  s3_aware_remote_file "/opt/#{node["oozie"]["archive-name"]}" do
    source "s3://sda-artifacts/oozie/#{node["oozie"]["archive-name"]}"
    access_key_id s3['access_key']
    secret_access_key s3['secret_key']
    owner node["hadoop"]["username"]
    group node["hadoop"]["group"]
    mode 0644
    not_if "test -e /opt/#{node["oozie"]["archive-name"]}"
  end

  script "download_extjs" do
    interpreter "bash"
    not_if "test -f /opt/#{node["oozie"]["extjs"]["archive-name"]}"
    user "root"
    cwd "/opt"
    code <<-EOH
  wget --output-document=/opt/#{node["oozie"]["extjs"]["archive-name"]} #{node["oozie"]["extjs"]["download_url"]} 
  EOH
  end

when "local"
  cookbook_file "/opt/#{node["oozie"]["archive-name"]}" do
    source "artifacts/#{node["oozie"]["archive-name"]}"
    mode "0644"
    action :create_if_missing
  end

  cookbook_file "/opt/#{node["oozie"]["extjs"]["archive-name"]}" do
    source "artifacts/#{node["oozie"]["extjs"]["archive-name"]}"
    mode "0644"
    owner "#{node["hadoop"]["username"]}"
    group "#{node["hadoop"]["group"]}"
    action :create_if_missing
  end
end

script "extract_oozie" do
  interpreter "bash"
  not_if "test -d /opt/#{node["oozie"]["folder-name"]}/conf"
  user "root"
  cwd "/opt"
  code <<-EOH
tar -zxf #{node["oozie"]["archive-name"]}
chown -R #{node["hadoop"]["username"]}:#{node["hadoop"]["group"]} #{node["oozie"]["folder-name"]}
#wget -c  #{node["oozie"]["extjs"]["download_url"]}
#chown -R #{node["hadoop"]["username"]}:#{node["hadoop"]["group"]} ext-2.2.zip
#{node["oozie"]["folder-name"]}/bin/oozie-setup.sh -hadoop 0.20.200 /opt/#{node["hadoop"]["folder-name"]} -extjs ext-2.2.zip
rm -rf /opt/#{node["oozie"]["folder-name"]}/data/oozie-db/*
EOH
end

ENV['USER'] = "#{node["hadoop"]["username"]}"

template "/opt/#{node["oozie"]["folder-name"]}/conf/oozie-site.xml" do
  owner "#{node["hadoop"]["username"]}"
  group "#{node["hadoop"]["group"]}"
  mode "0644"
  source "oozie-site.xml.erb"
  #notifies :restart, resources(:service => "hadoop-0.20-datanode")
  #notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

script "fix_oozie_permissions" do
  interpreter "bash"
  user "root"
  cwd "/opt"
  code <<-EOH
chown -R #{node["hadoop"]["username"]}:#{node["hadoop"]["group"]} /opt/#{node["oozie"]["folder-name"]}
EOH
end

if platform?("redhat", "centos", "fedora")
  template "/etc/init.d/oozie" do
    source "oozie.init"
    owner "root"
    group "root"
    mode 0755
  end

  service "oozie" do
    service_name "oozie"
    pattern "oozie"
    start_command "/etc/init.d/oozie start"
    stop_command "/etc/init.d/oozie stop"
    status_command "ps auwwx | grep oozie | grep -v grep"
    restart_command"/etc/init.d/oozie stop && sleep 10 && /etc/init.d/oozie start"
    action [ :enable, :start ]
    supports :start => true, :stop => true, :restart => true, :status => true, :reload => false
  end
end

if platform?("ubuntu")
include_recipe "runit"
ENV['SVWAIT'] = "#{node["runit"]["svwait"]}"

runit_service "oozie" do 
  action :start
end
end
