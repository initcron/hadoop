default['kafka']['version'] = "0.7.1"
default['kafka']['tarball'] = "kafka-#{node["kafka"]["version"]}-rc3.tar.gz"
default['kafka']['url'] = "https://s3.amazonaws.com/initcron-artifacts/kafka-#{node["kafka"]["version"]}-rc3.tar.gz"
default['kafka']['home'] = "/opt/kafka-#{node["kafka"]["version"]}"
default['kafka']['jmx'] = "3008"
default['kafka']['zkChroot'] = "kafka";
set_unless["kafka"]["host"] = "localhost"
default['kafka']['port'] = "9092"

