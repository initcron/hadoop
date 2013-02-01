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

case "#{node.install.type}"
when "remote"
  script "Download Pig" do
    interpreter "bash"
    not_if "test -e /opt/#{node["pig"]["archive-name"]}"
    user "root"
    cwd "/opt"
    code <<-EOH 
    wget -c  #{node["pig"]["download-url"]}
  EOH
  end
when "local"
  cookbook_file "/opt/#{node["pig"]["archive-name"]}" do
    source "artifacts/#{node["pig"]["archive-name"]}"
    mode "0644"
    action :create_if_missing
  end
end

script "Extract Pig" do
  interpreter "bash"
  not_if "test -d /opt/#{node["pig"]["folder-name"]}/conf"
  user "root"
  cwd "/opt"
  code <<-EOH
#wget -c  #{node["pig"]["download-url"]}
tar -zxf #{node["pig"]["archive-name"]}
chown -R #{node["hadoop"]["username"]} #{node["pig"]["folder-name"]}
EOH
end

ENV['USER'] = "#{node["hadoop"]["username"]}"

template "/opt/#{node["pig"]["folder-name"]}/conf/pig.properties" do
  owner "#{node["hadoop"]["username"]}"
  group "#{node["hadoop"]["group"]}"
  mode "0644"
  source "pig.properties.erb"
  #notifies :restart, resources(:service => "hadoop-0.20-datanode")
  #notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

