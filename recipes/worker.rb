tag('worker')

include_recipe 'chef-vault'
include_recipe 'runit'
include_recipe 'git'
include_recipe 'postgresql::client'
include_recipe "sandy::_user"
include_recipe "sandy::_ruby"
include_recipe "sandy::_application"

directory node['sandy']['worker']['home'] do
  owner 'processing'
  group 'processing'
  recursive true
end

directory "#{node['sandy']['worker']['home']}/shared" do
  owner 'processing'
  group 'processing'
  recursive true
end

directory "#{node['sandy']['worker']['home']}/shared/bundle" do
  owner 'processing'
  group 'processing'
  recursive true
end

directory "#{node['sandy']['worker']['home']}/shared/config" do
  owner 'processing'
  group 'processing'
  recursive true
end

confs = data_bag_item(:apps, 'sandy-utils-production')['configs']

confs.each do |f, conf|
  file "#{node['sandy']['worker']['home']}/shared/config/#{f}" do
    owner 'processing'
    group 'processing'
    mode 0644
    content conf.to_yaml
  end
end

deploy_revision node['sandy']['worker']['home'] do
  repo node['sandy']['worker']['repo']
  revision node['sandy']['worker']['revision']
  user 'processing'
  group 'processing'
  action node['sandy']['worker']['deploy_action'] || 'deploy'

  symlinks(confs.reduce({}){|result, (k,v)| result["config/#{k}"] = "config/#{k}"; result })

  before_restart do
    execute 'bundle install' do
      cwd release_path
      user 'processing'
      group 'processing'
      command "bundle install --without test development --path=#{node['sandy']['worker']['home']}/shared/bundle"
    end
  end
end

runit_service "sidekiq" do
  action [:enable, :start]
  log true
  default_logger true
  env({
    "RAILS_ENV" => 'production',
    "PROCESSING_NUMBER_OF_CPUS" => "#{node['cpu']['total']}"
    })

  subscribes :restart, "deploy_revision[#{node['sandy']['home']}]", :delayed
  subscribes :restart, "template[#{node['sandy']['home']}/shared/.env.production]", :delayed
end
