remote_file "/tmp/rubygems-#{node[:rubygems][:version]}.tgz" do
  source "http://production.cf.rubygems.org/rubygems/rubygems-#{node[:rubygems][:version]}.tgz"
  not_if do
    File.exists?("/tmp/rubygems-#{node[:rubygems][:version]}.tgz")
  end
end

execute "tar xvfz rubygems-#{node[:rubygems][:version]}.tgz" do
  cwd "/tmp"
  umask 022
  not_if do
    File.exists?("/tmp/rubygems-#{node[:rubygems][:version]}")
  end
end

execute "Updating Rubygems to #{node[:rubygems][:version]}" do
  command "/usr/local/bin/ruby setup.rb"
  cwd "/tmp/rubygems-#{node[:rubygems][:version]}"
  umask 022
  not_if do
    File.exists?('/usr/local/bin/gem') && `/usr/local/bin/gem -v`.strip == node[:rubygems][:version]
  end
end