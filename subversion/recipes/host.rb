group "deploy"

user "deploy" do
  action :create
  comment "deploy user"
  gid "deploy"
  home "/home/deploy"
  supports :manage_home => true
  shell "/bin/zsh"
end

%w{deploy root}.each do |user|
  home = user == "root" ? "/root" : "/home/#{user}"

  directory "#{home}/.subversion/auth/" do
    action :create
    recursive true
    owner user
    mode "0700"
  end

  directory "#{home}/.subversion/auth/svn.ssl.server" do
    action :create
    recursive true
    owner user
    mode "0755"
  end

  directory "#{home}/.subversion/auth/svn.simple" do
    action :create
    recursive true
    owner user
    mode "0755"
  end

  remote_file "#{home}/.subversion/auth/svn.ssl.server/92cacd77b0d9a00c766ab3b920dac6d2" do
    source "auth"
    owner user
    mode '0644'
  end

  remote_file "#{home}/.subversion/auth/svn.simple/a3ee8e2da256e7b939e3a3b66b8799a5" do
    source "auth2"
    owner user
    mode '0644'
  end

end