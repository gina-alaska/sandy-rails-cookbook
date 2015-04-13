tag('web')

include_recipe 'chef-vault'
include_recipe 'runit'
include_recipe 'git'
include_recipe 'postgresql::client'
include_recipe "sandy::_user"
include_recipe "sandy::_ruby"
include_recipe "sandy::_application"


runit_service "puma" do
  action [:start, :enable]
  env Sandy::Config.environment_for(environment)

  subscribes :restart, "deploy_revision[#{node['sandy']['home']}]"
  subscribes :restart, "template[#{node['sandy']['home']}/shared/.env.production]"
end

include_recipe "sandy::_nginx"
