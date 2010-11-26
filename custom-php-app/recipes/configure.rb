node[:deploy].each do |application, deploy|
  
  # DB config
  template "#{deploy[:deploy_to]}/current/config/db.inc.php" do
    source "db.inc.php.erb"
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:database => deploy[:database], :application => application)
    
    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/config/db.inc.php")
    end
  end
  
  
  # Memcache config
  template "#{deploy[:deploy_to]}/current/config/memcache.inc.php" do
    source "memcache.inc.php.erb"
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:memcached => deploy[:memcached], :application => application)
    
    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/config/memcache.inc.php")
    end
  end
  
  # random custom role
  redis_server = node[:scalarium][:roles][:redis][:instances].keys.first
  
  template "#{deploy[:deploy_to]}/current/config/redis.inc.php" do
    source "redis.inc.php.erb"
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:host => node[:scalarium][:roles][:redis][:instances][redis_server][:private_dns_name])

    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/config/redis.inc.php")
    end
  end
  
end