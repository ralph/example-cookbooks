default[:resque] = {}
default[:resque][:version] = '1.10.0'
default[:resque][:queues] = '*'
default[:resque][:workers] = {"*" => 5}
default[:resque][:max_memory] = 300
default[:resque][:web] = {}
default[:resque][:web][:enabled] = true
