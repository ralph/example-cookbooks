node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping sphinx::client as application #{application} is not a Rails application")
    next
  else
    Chef::Log.debug("Running sphinx::client for Rails application #{application}")
  end
 
  directory "#{deploy[:deploy_to]}/current/config/thinkingsphinx" do
    action :create
    owner deploy[:user]
    group deploy[:group]
    mode "0755"
  end

  if node[:scalarium][:instance][:roles].include?("rails-app")
    execute "restart Rails app #{application}" do
      cwd deploy[:current_path]
      command "touch tmp/restart.txt"
      action :nothing
    end
  end

  template "#{deploy[:deploy_to]}/current/config/sphinx.yml" do
    source "sphinx.yml.erb"
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    
    only_if do
      File.directory?("#{deploy[:deploy_to]}/current")
    end

    host = node[:scalarium][:roles][:sphinx][:instances].collect{|instance, names| names["private_dns_name"]}.first

    variables :application => application,
              :deploy => deploy,
              :host => host
    if node[:scalarium][:instance][:roles].include?("rails-app") and deploy[:stack][:needs_reload]
      notifies :run, resources(:execute => "restart Rails app #{application}")
    end
  end
end
