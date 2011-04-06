package "nfs-common"

node[:nfs][:exports].each do |mount_point|
  directory mount_point do
    recursive true
    mode "0777"
  end

  mount mount_point do
    fstype "nfs"
    options node[:nfs][:mount_options]
    device "#{node[:nfs][:server]}:#{mount_point}"
    dump 0
    pass 0
    # mount and add to fstab. set to 'disable' to remove it
    action [:enable, :mount]
  end
end