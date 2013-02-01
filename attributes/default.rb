include_attribute "java"
include_attribute "zookeeper"

default["default"]["zkClientPort"] = "2181"
default["runit"]["svwait"] = 180
#Install Type. Accepted values are local,remote. Defaults to remote. 
# If changed to local, installers are fetched from local path
default["install"]["type"] = "remote" 
default["chef"]["solo"] = false
default["heartbeat"]["enabled"] = true
