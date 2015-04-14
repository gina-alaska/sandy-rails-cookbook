tag('web')
node.set['sandy']['precompile_assets'] = true
include_recipe 'chef-vault'
include_recipe 'runit'
include_recipe 'git'
include_recipe 'postgresql::client'
include_recipe "sandy::_user"
include_recipe "sandy::_ruby"
include_recipe "sandy::_application"


runit_service "puma" do
  action [:enable, :start]
  log true
  default_logger true
  env({
    "RAILS_ENV" => 'production',
    "PORT" => node['sandy']['puma_port']
  })

  subscribes :restart, "deploy_revision[#{node['sandy']['home']}]", :delayed
  subscribes :restart, "template[#{node['sandy']['home']}/shared/.env.production]", :delayed
end

include_recipe "sandy::_nginx"
