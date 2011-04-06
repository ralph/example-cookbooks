default[:nfs][:exports] = ["/vol/data"]
default[:nfs][:clients] = scalarium[:roles]['php-app'][:instances].values.map{|config| config[:private_ip]}
default[:nfs][:server] = scalarium[:roles]['nfs'][:instances].values.map{|config| config[:private_ip]}.first

default[:nfs][:mount_options] = %w(rsize=32768,wsize=32768,bg,hard,nfsvers=3,intr,tcp)