default[:backup][:directory] = "/vol/backups" # prefferably an EBS disk
default[:backup][:databases] = ["my_app_production", "thing_2"] # you could also use node[:deploy].keys