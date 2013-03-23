package 'git-core'

torquebox                   = node[:torquebox]
torquebox[:example_gitrepo] = "git://github.com/LevelbossMike/tb_example.git"
torquebox[:example_home]    = '/var/www/example'

directory "/var/www/" do
  recursive true
end

git "/var/www/example" do
  repository torquebox[:example_gitrepo]
  revision "HEAD"
  destination torquebox[:example_home]
  action :sync
end

execute "bundle install" do
  command "jruby -S bundle install"
  cwd torquebox[:example_home]
  not_if "jruby -S bundle check"
end

torquebox_application "example" do
  action :deploy
  path torquebox[:example_home]
end

execute "chown app directory" do
  command "chown -R torquebox:torquebox #{torquebox[:example_home]}"
end
