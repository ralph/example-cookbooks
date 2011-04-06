package "nfs-common"
package "nfs-kernel-server"

template "/etc/exports" do
  source "exports.erb"
  owner "root"
  group "root"
  mode 0644
end

execute "re-export" do
  command "exportfs -ar"
end