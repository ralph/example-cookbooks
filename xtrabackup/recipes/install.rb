remote_file "/tmp/#{node[:xtrabackup][:deb]}" do
  source "http://www.percona.com/downloads/XtraBackup/XtraBackup-1.4/deb/karmic/i686/#{node[:xtrabackup][:deb]}"
end

execute "dpkg -i #{node[:xtrabackup][:deb]}" do
  cwd "/tmp"
end

directory File.dirname(node[:xtrabackup][:executable]) do
  action :create
  recursive true
  owner 'root'
  mode 0755
end

template node[:xtrabackup][:executable] do
  source "db-backup.rb.erb"
  mode 0777
end

cron "xtrabackup cronjob" do
  command node[:xtrabackup][:executable]
  hour "2"
  minute "0"
end
