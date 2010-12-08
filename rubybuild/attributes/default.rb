default[:ruby] = {}
default[:ruby][:version] = '1.9.2'
default[:ruby][:patch] = 'p0'
default[:ruby][:basename] = "ruby-#{node[:ruby][:version]}-#{node[:ruby][:patch]}"
default[:ruby][:pkgrelease] = '1'
default[:ruby][:prefix] = '/usr/local'
default[:ruby][:configure] = '--enable-shared --disable-install-doc'
