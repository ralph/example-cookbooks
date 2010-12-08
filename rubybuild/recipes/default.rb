execute "apt-get update"
package "checkinstall"
package "libffi-dev"

remote_file "/tmp/#{node[:ruby][:basename]}.tar.bz2" do
  source "http://ftp.ruby-lang.org/pub/ruby/#{node[:ruby][:basename]}.tar.bz2"
end

execute "tar xvfj #{node[:ruby][:basename]}.tar.bz2" do
  cwd "/tmp"
end

execute "./configure --prefix=#{node[:ruby][:prefix]} #{node[:ruby][:configure]}" do
  cwd "/tmp/#{node[:ruby][:basename]}"
end

execute "checkinstall -y -D --pkgname=ruby1.9 --pkgversion=#{node[:ruby][:version]} --pkgrelease=#{node[:ruby][:patch]}.#{node[:ruby][:pkgrelease]} --maintainer=mathias.meyer@scalarium.com --pkggroup=ruby --pkglicense='Ruby License' make all install" do
  cwd "/tmp/#{node[:ruby][:basename]}"
end
