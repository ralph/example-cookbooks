execute "apt-get update"

package "s3cmd" do
  only_if do
    node[:nodejsbuild][:s3][:upload]
  end
end

package "checkinstall"

case node[:platform]
when "ubuntu","debian"
  %w{build-essential binutils-doc}.each do |pkg|
    package pkg do
      action :install
    end
  end
when "centos"
  package "gcc" do
    action :install
  end
end

package "autoconf" do
  action :install
end

package "flex" do
  action :install
end

package "bison" do
  action :install
end

case node[:platform]
  when "centos","redhat","fedora"
    package "openssl-devel"
  when "debian","ubuntu"
    package "libssl-dev"
end

('0.4.0' .. '0.4.7').each do |version|
  node[:nodejsbuild][:version] = version
  node[:nodejsbuild][:basename] = "nodejs-#{node[:nodejsbuild][:version]}"
  node[:nodejsbuild][:deb] = "nodejs_#{node[:nodejsbuild][:version]}-#{node[:nodejsbuild][:pkgrelease]}_#{node[:nodejsbuild][:arch]}.deb"

  remote_file "/tmp/#{node[:nodejsbuild][:basename]}.tar.gz" do
    source "http://nodejs.org/dist/node-v#{node[:nodejsbuild][:version]}.tar.gz"
  end

  execute "tar xvfz #{node[:nodejsbuild][:basename]}.tar.gz" do
    cwd "/tmp"
  end

  execute "./configure --prefix=#{node[:nodejsbuild][:prefix]}" do
    cwd "/tmp/node-v#{node[:nodejsbuild][:version]}"
  end

  execute "checkinstall -y -D --pkgname=nodejs --pkgversion=#{node[:nodejsbuild][:version]} --pkgrelease=#{node[:nodejsbuild][:pkgrelease]} --maintainer=daniel.huesch@scalarium.com --pkglicense='node.js License' make all install" do
    cwd "/tmp/node-v#{node[:nodejsbuild][:version]}"
  end

  template "/tmp/.s3cfg" do
    source "s3cfg.erb"
    only_if do
      node[:nodejsbuild][:s3][:upload]
    end
  end

  execute "s3cmd -c /tmp/.s3cfg put --acl-public --guess-mime-type #{node[:nodejsbuild][:deb]} s3://#{node[:nodejsbuild][:s3][:bucket]}/#{node[:nodejsbuild][:s3][:path]}/" do
    cwd "/tmp/node-v#{node[:nodejsbuild][:version]}"
    only_if do
      node[:nodejsbuild][:s3][:upload]
    end
  end

  file "/tmp/.s3cfg" do
    action :delete
    backup false
  end
end
