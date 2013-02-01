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

# Settings for /etc/hadoop/conf/mapred-site.xml

default[:Hadoop][:Jobtracker][:Host] = "localhost"
default[:Hadoop][:Jobtracker][:Port] = "50002"
default[:Hadoop][:Mapred][:mapredJobTracker] = "hdfs://#{default['Hadoop']['Jobtracker']['Host']}:#{default['Hadoop']['Jobtracker']['Port']}"
#default[:Hadoop][:Mapred][:mapredSystemDir] = "/mapred/system"
#default[:Hadoop][:Mapred][:mapredUserlogRetainHours] = "48"
#default[:Hadoop][:Mapred][:mapredJobtrackerTaskScheduler] = "org.apache.hadoop.mapred.FairScheduler"
#default[:Hadoop][:Mapred][:mapredFairschedulerAllocationFile] = "/etc/hadoop/conf/fair-scheduler.xml"
#default[:Hadoop][:Mapred][:mapredFairschedulerPreemption] = "true"
#default[:Hadoop][:Mapred][:mapredFairschedulerAssignmultiple] = "true"
#default[:Hadoop][:Mapred][:mapredFairschedulerPoolnameproperty] = "user.name"

# General Tasks
default[:Hadoop][:Mapred][:mapredJobReuseJvmNumTasks] = "-1"
default[:Hadoop][:Mapred][:mapredMaxTrackerFailures] = "100"

# Map Tasks
default[:Hadoop][:Mapred][:mapredMapChildJavaOpts] = "-Xmx2048M"
default[:Hadoop][:Mapred][:mapredTasktrackerMapTasksMaximum] = "4"
default[:Hadoop][:Mapred][:mapredMapMaxAttempts] = "100"
default[:Hadoop][:Mapred][:mapredMapTasksSpeculativeExecution] = "true"

# Reduce Tasks
default[:Hadoop][:Mapred][:mapredReduceChildJavaOpts] = "-Xmx4096M"
default[:Hadoop][:Mapred][:mapredTasktrackerReduceTasksMaximum] = "3"
default[:Hadoop][:Mapred][:mapredReduceMaxAttempts] = "100"
default[:Hadoop][:Mapred][:mapredReduceTasksSpeculativeExecution] = "true"

#default[:Hadoop][:Mapred][:mapredJobTrackerHandlerCount] = "10"
default[:Hadoop][:Mapred][:reduceParallelCopies] = "5"
#default[:Hadoop][:Mapred][:mapredReduceSlowstartCompletedMaps] = "0.5"
#default[:Hadoop][:Mapred][:mapredReduceTasks] = "75"
#default[:Hadoop][:Mapred][:tasktrackerHttpThreads] = "45"
default[:Hadoop][:Mapred][:ioSortMb] = "100"
default[:Hadoop][:Mapred][:ioSortFactor] = "10"
