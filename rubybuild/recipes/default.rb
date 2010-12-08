execute "apt-get update"
package "s3cmd" do
  only_if do
    node[:ruby][:s3][:upload]
  end
end

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

template "#{ENV["HOME"]}/.s3cfg" do
  source "s3cfg.erb"
  only_if do
    node[:ruby][:s3][:upload]
  end
end

execute "s3cmd put --acl-public --guess-mime-type #{node[:ruby][:deb]} s3://#{node[:ruby][:s3][:bucket]}/#{node[:ruby][:deb]}" do
  cwd "/tmp/#{node[:ruby][:basename]}"
  only_if do
    node[:ruby][:s3][:upload]
  end
end
