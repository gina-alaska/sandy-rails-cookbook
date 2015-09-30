tag('web')
node.set['sandy']['precompile_assets'] = true
include_recipe 'chef-vault'
include_recipe 'runit'
include_recipe 'git'
include_recipe 'postgresql::client'
include_recipe "sandy::_user"
include_recipe "sandy::_ruby"
include_recipe "sandy::_application"

cron "fetch-upcoming-pass-info" do
  time :daily
  command "/bin/bash -l -c 'cd /opt/sandy/embedded/service/sandy && bin/rails runner -e production '\''Facility.queue_upcoming_passes'\'''"
  environment({"PATH" => "$PATH:/opt/sandy/embedded/bin"})
  user 'processing'
end

cron 'cleanup-old-passes' do
  time :hourly
  command "/bin/bash -l -c 'cd /opt/sandy/embedded/service/sandy && bin/rails runner -e production '\''Pass.cleanup_old_passes'\'''"
  environment({"PATH" => "$PATH:/opt/sandy/embedded/bin"})
  user 'processing'
end

runit_service "puma" do
  action [:enable, :start]
  log true
  default_logger true
  env({
    "RAILS_ENV" => 'production',
    "PORT" => node['sandy']['puma_port'],
    "PUMA_PIDFILE" => "#{node['sandy']['home']}/shared/pids/puma.pid"
  })
  options({
    release_path: "#{node['sandy']['home']}/current"
  })

  ignore_failure true
  subscribes :usr1, "deploy_revision[#{node['sandy']['home']}]", :delayed
  subscribes :usr1, "template[#{node['sandy']['home']}/shared/.env.production]", :delayed
end

include_recipe "sandy::_nginx"
