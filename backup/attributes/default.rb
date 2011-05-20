default[:backup][:mysql][:directory] = "/vol/backups" # prefferably an EBS disk
default[:backup][:mysql][:databases] = ["my_app_production", "thing_2"] # you could also use node[:deploy].keys
default[:backup][:mysql][:keep] = 10