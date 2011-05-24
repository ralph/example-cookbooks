include_recipe "deploy::user"
include_recipe "deploy::directory"

# No need to check out the source when we're on a Rails
# App Server.
unless node[:scalarium][:instance][:roles].include?('rails-app')
  node[:deploy].each do |application, deploy|
    prepare_git_checkouts(:user => deploy[:user], 
                        :group => deploy[:group], 
                        :home => deploy[:home], 
                        :ssh_key => deploy[:scm][:ssh_key]) if deploy[:scm][:scm_type].to_s == 'git'

    %w(log config system pids).each do |dir_name|
      directory "#{deploy[:deploy_to]}/shared/#{dir_name}" do
        group deploy[:group]
        owner deploy[:user]
        mode "0770"
        action :create
        recursive true  
      end
    end

    directory "#{deploy[:deploy_to]}/shared/cached-copy" do
      recursive true
      action :delete
    end

    deploy deploy[:deploy_to] do
      repository deploy[:scm][:repository]
      user deploy[:user]
      revision deploy[:scm][:revision]
      migrate false
      environment "RAILS_ENV" => deploy[:rails_env], "RUBYOPT" => ""
      symlink_before_migrate({})
      restart_command "echo"
      action deploy[:action]
      case deploy[:scm][:scm_type].to_s
      when 'git'
        scm_provider Chef::Provider::Git
        enable_submodules deploy[:enable_submodules]
        shallow_clone true
      when 'svn'
        scm_provider Chef::Provider::Subversion
        svn_username deploy[:scm][:user]
        svn_password deploy[:scm][:password]
      else
        raise "unsupported SCM type #{deploy[:scm][:scm_type].inspect}"
      end
      before_migrate lambda{}
      after_restart lambda{}
      before_symlink do
        if deploy[:auto_bundle_on_deploy]
          Scalarium::RailsConfiguration.bundle(application, node[:deploy][application], release_path)
        end
      end
      before_restart lambda{}
    end

    template "#{deploy[:deploy_to]}/current/config/database.yml" do
      source "database.yml.erb"
      mode "0660"
      group deploy[:group]
      owner deploy[:user]
      variables(:database => deploy[:database], :environment => deploy[:rails_env])
      cookbook "rails" 
    end

    execute "fix access rights on deployment directory" do
      command "chmod o-w #{deploy[:deploy_to]}"
      action :run
    end
  end
end

include_recipe 'sphinx::client'

node[:deploy].each do |application, deploy|
  directory "/var/log/sphinx" do
    action :create
    owner deploy[:user]
    group deploy[:group]
    mode "0755"
  end

  directory "/var/run/sphinx" do
    action :create
    owner deploy[:user]
    group deploy[:group]
    mode "0755"
  end

  execute "rake thinking_sphinx:configure" do
    cwd "#{deploy[:deploy_to]}/current"
    user deploy[:user]
    environment 'RAILS_ENV' => deploy[:rails_env], "HOME" => "/home/#{deploy[:user]}"
  end

  execute 'rake thinking_sphinx:rebuild' do
    cwd "#{deploy[:deploy_to]}/current"
    user deploy[:user]
    environment 'RAILS_ENV' => deploy[:rails_env], "HOME" => "/home/#{deploy[:user]}"
  end

  cron "sphinx reindex cronjob" do
    action  :create
    minute  "*/#{node[:sphinx][:cron_interval]}"
    hour    '*'
    day     '*'
    month   '*'
    weekday '*'
    command "cd #{deploy[:deploy_to]}/current && RAILS_ENV=#{deploy[:rails_env]} rake thinking_sphinx:index"
    user deploy[:user]
    path "/usr/bin:/usr/local/bin:/bin"
  end

  template "/etc/monit/conf.d/sphinx_#{application}.monitrc" do
    source "sphinx.monitrc.erb"
    owner "root"
    mode "0644"
    variables :application => application, :deploy => deploy
  end

  execute "monit reload" do
  end
end
