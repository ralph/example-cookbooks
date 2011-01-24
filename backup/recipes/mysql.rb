directory "#{node[:backup][:directory]}/mysql" do
  action :create
  recursive true
  mode 0750
end

node[:backup][:databases].each_with_index do |db, index|

  cron "Backup MySQL #{db}" do
    minute "15"
    hour( (2 + index).to_s)
    command "mysqldump -u root -p#{node[:mysql][:server_root_password]} #{db} | gzip > #{node[:backup][:directory]}/mysql/#{db}_`date +%Y_%m_%d_%H_%M_%S`.sql.gz"
  end

end