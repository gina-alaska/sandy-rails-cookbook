tag('web')
node.set['sandy']['precompile_assets'] = true
include_recipe 'chef-vault'
include_recipe 'runit'
include_recipe 'git'
include_recipe 'postgresql::client'
include_recipe "sandy::_user"
include_recipe "sandy::_application"


directory '/var/run/sandy' do
  owner 'processing'
  group 'processing'
end

runit_service "puma" do
  action [:enable, :start]
  log true
  default_logger true
  env({
    "RAILS_ENV" => 'production',
    "PORT" => node['sandy']['puma_port'],
    "PUMA_PIDFILE" => "/var/run/sandy/puma.pid"
  })

  subscribes :usr1, "install_package[sandy]", :delayed
  subscribes :usr1, "template[#{node['sandy']['home']}/embedded/service/sandy/.env]", :delayed
end

include_recipe "sandy::_nginx"
