package "gzip"

directory "#{node[:backup][:mysql][:directory]}/mysql" do
  action :create
  recursive true
  mode 0750
end

template "/root/backup_mysql" do
  source 'backup_mysql.erb'
  mode '755'
end

cron "Backup MySQL" do
  minute "15"
  hour "2"
  command "/root/backup_mysql"
end