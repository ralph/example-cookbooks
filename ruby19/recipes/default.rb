package "libreadline-dev" do
  action :install
end

package "libncurses5-dev" do
  action :install
end

package "libssl-dev" do
  action :install
end

directory "/tmp/ruby19_install" do
  mode "0755"
  action :create
end

remote_file "/tmp/ruby19_install/#{node[:ruby19][:package_name]}" do
  source "#{node[:ruby19][:package_url]}"
  mode "0644"
  action :create_if_missing
  not_if "test -f #{node[:ruby19][:link_dir]}/bin/ruby"
end

execute "untar ruby19 archive" do
 command <<-CMD
    tar xjf #{node[:ruby19][:package_name]}
    cd /tmp/ruby19_install/ruby-#{node[:ruby19][:version]}
    ./configure --prefix=#{node[:ruby19][:target_dir]} && make && make install
    rm -f #{node[:ruby19][:link_dir]}
    ln -s #{node[:ruby19][:target_dir]} #{node[:ruby19][:link_dir]}
    cd #{node[:ruby19][:link_dir]}
    #{node[:ruby19][:link_dir]}/bin/gem update --system
    rm #{node[:ruby19][:gem_dir]}/../specifications/rake.gemspec
  CMD
  cwd "/tmp/ruby19_install"
  
  not_if "test -f #{node[:ruby19][:link_dir]}/bin/ruby"
end

