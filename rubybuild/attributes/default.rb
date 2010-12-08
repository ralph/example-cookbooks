default[:ruby] = {}
default[:ruby][:version] = '1.9.2'
default[:ruby][:patch] = 'p0'
default[:ruby][:basename] = "ruby-#{node[:ruby][:version]}-#{node[:ruby][:patch]}"
default[:ruby][:pkgrelease] = '1'
default[:ruby][:prefix] = '/usr/local'
default[:ruby][:configure] = '--enable-shared --disable-install-doc'
default[:ruby][:arch] = node[:kernel][:machine] == 'x86_64' ? 'amd64' : 'i386'
default[:ruby][:deb] = "ruby1.9_#{node[:ruby][:version]}-#{node[:ruby][:patch]}.#{node[:ruby][:pkgrelease]}_#{node[:ruby][:arch]}.deb"
default[:ruby][:s3] = {}
default[:ruby][:s3][:upload] = false
default[:ruby][:s3][:bucket] = ''
default[:ruby][:s3][:path] = "#{node[:platform]}/#{node[:platform_version]}/#{node[:ruby][:deb]}"
default[:ruby][:s3][:aws_access_key] = ""
default[:ruby][:s3][:aws_secret_access_key] = ""
