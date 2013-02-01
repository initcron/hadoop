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
  script "Download Hive" do
    interpreter "bash"
    not_if "test -e #{node["hive"]["archive-name"]}"
    user "root"
    cwd "/opt"
    code <<-EOH
  wget -c  #{node["hive"]["download-url"]}
  EOH
  end
when "local"
  cookbook_file "/opt/#{node["hive"]["archive-name"]}" do
    source "artifacts/#{node["hive"]["archive-name"]}"
    mode "0644"
    action :create_if_missing
  end
end

script "Extract Hive" do
  interpreter "bash"
  not_if "test -d /opt/#{node["hive"]["folder-name"]}/conf"
  user "root"
  cwd "/opt"
  code <<-EOH
#wget -c  #{node["hive"]["download-url"]}
tar -zxf #{node["hive"]["archive-name"]}
chown -R #{node["hadoop"]["username"]} #{node["hive"]["folder-name"]}
EOH
end

script "create_hive_tmp" do
  interpreter "bash"
  not_if "/opt/#{node["hadoop"]["folder-name"]}/bin/hadoop fs -ls /tmp > /dev/null"
  user "root"
  cwd "/opt"
  code <<-EOH
/opt/#{node["hadoop"]["folder-name"]}/bin/hadoop fs -mkdir /tmp
/opt/#{node["hadoop"]["folder-name"]}/bin/hadoop fs -chmod g+w /tmp
EOH
end

script "create_hive_warehouse" do
  interpreter "bash"
  not_if "/opt/#{node["hadoop"]["folder-name"]}/bin/hadoop fs -ls /user/hive/warehouse > /dev/null"
  user "root"
  cwd "/opt"
  code <<-EOH
/opt/#{node["hadoop"]["folder-name"]}/bin/hadoop fs -mkdir /user/hive/warehouse
/opt/#{node["hadoop"]["folder-name"]}/bin/hadoop fs -chmod g+w /user/hive/warehouse
EOH
end

script "update_hive_home_env_var" do
  interpreter "bash"
  user "root"
  code <<-EOH
echo "export HIVE_HOME=/opt/#{node["hive"]["folder-name"]}" >> /etc/environment
source /etc/environment
EOH
  not_if "grep HIVE_HOME /etc/environment"
end


