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

# Settings for /etc/hadoop/conf/core-site.xml
#set_unless[:zookeeper][:cluster_name] = "zookeeper"
default[:hadoop][:cluster] = "hadoopcluster"
default[:Hadoop][:Version] = "1.0.4"
set_unless['Hadoop']['Master'] = "localhost"
default["Hadoop"]["Namenode"]["Port"] = "50001"
default['hadoop']['username'] = 'hadoop'
default['hadoop']['group'] = 'hadoop'
default['hadoop']['tmp']['dir'] = '/mnt/tmp'
#default["hadoop"]["password"] = "$6$Rd0g63z95/$eSUZVufg.DytP.ETlrnzZWxRh19VgMZTG5QTRddNbZu0pyddjm1c0WSLamJ8a.N.bAA6dijr6684yTm0WzVBo." #hadoop
default["hadoop"]["download-url"] = "http://archive.apache.org/dist/hadoop/common/hadoop-#{default['Hadoop']['Version']}/hadoop-#{default['Hadoop']['Version']}-bin.tar.gz"
default["hadoop"]["archive-name"] = "hadoop-#{default['Hadoop']['Version']}-bin.tar.gz"
default["hadoop"]["folder-name"] = "hadoop-#{default['Hadoop']['Version']}"
#default["hadoop"]["hdfs-folder"] = "/home/#{default['hadoop']['username']}/hdfs"
default[:Hadoop][:Core][:hadoopTmpDir] = "/data/tmp"
#default[:Hadoop][:Core][:fsDefaultName] = "hdfs://#{default['Hadoop']['Master']}:50001"
#default[:Hadoop][:Core][:ioFileBufferSize] = "65536"
#default[:Hadoop][:Core][:ioCompressionCodecs] = "org.apache.hadoop.io.compress.GzipCodec,org.apache.hadoop.io.compress.DefaultCodec"
set_unless[:Hadoop][:Core][:hadoopProxyuserOozieHosts] = "oozie.example.com"
#default[:Hadoop][:Core][:hadoopProxyuserOozieGroups] = "*"

default['ebs']['size'] = 100
default['ebs']['dev'] = '/dev/sdp'
case platform
when "centos","redhat","fedora","scientific","amazon"
  default['ebs']['dev-ec2'] = '/dev/sdp'
when "ubuntu"
  default['ebs']['dev-ec2'] = '/dev/xvdp'
else
  default['ebs']['dev-ec2'] = '/dev/sdp'
end


