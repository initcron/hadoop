#default['oozie']['version'] = '3.0.2'
#default["oozie"]["download-url"] = "https://github.com/downloads/yahoo/oozie/oozie-#{node["oozie"]["version"]}-distro.tar.gz"

default['oozie']['version'] = '3.2.0'
default["oozie"]["download-url"] = "http://apache.petsads.us/incubator/oozie/oozie-#{node["oozie"]["version"]}-incubating/oozie-#{node["oozie"]["version"]}-incubating-distro.tar.gz"
default["oozie"]["archive-name"] = "oozie-#{node["oozie"]["version"]}-SNAPSHOT-distro.tar.gz"
default["oozie"]["folder-name"] = "oozie-#{node["oozie"]["version"]}-SNAPSHOT"
default["oozie"]["extjs"]["download_url"] = "http://extjs.com/deploy/ext-2.2.zip"
default["oozie"]["extjs"]["archive-name"] = "ext-2.2.zip"


