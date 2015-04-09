include_recipe "chef-vault"
chef_gem 'foreman' do
  compile_time false
end

user node['sandy']['account']

packagecloud_repo "sdmacfarlane/demo" do
  type "rpm"
end

package node['sandy']['application']['name'] do
  version node['sandy']['application']['version']
  action :install
  notifies :create, "template[#{node['sandy']['install_dir']}/.env]", :immediately
end

database_config = chef_vault_item(:sandy, 'database')
database_host = search(:node, 'roles:sandy-database').first
database_host = node if database_host.nil?

influx_password = data_bag_item(:sandy, 'influxdb')['users']['sandy']['password']
influx_servers = search(:node, 'roles:sandy-influxdb').map(&:ipaddress)

redis_master = search(:node, 'roles:sandy-redis').first
redis_master = node if redis_master.nil?

env_path = [
  '/usr/bin',
  "#{node['sandy']['install_dir']}/bin",
  "#{node['sandy']['install_dir']}/embedded/bin",
  "#{node['sandy']['worker']['scripts-path']}/bin"
].join(':')

template "#{node['sandy']['install_dir']}/.env" do
  source 'foreman_env.erb'
  variables({ env: {
    rails_environment: node['sandy']['environment'],
    rails_database: "sandy_#{node['sandy']['environment']}",
    rails_database_username: 'sandy',
    rails_database_password: database_config['passwords']['sandy'],
    rails_database_host: database_host['ipaddress'],
    rails_secret_key_base: node['sandy']['rails']['secret_key_base'],
    influxdb_database: 'sandy-metrics',
    influxdb_username: 'sandy',
    influxdb_password: influx_password,
    influxdb_servers: influx_servers,
    sidekiq_queue: node['sandy']['worker']['queue'],
    redis_url: "redis://#{redis_master['ipaddress']}:6379",
    redis_namespace: node['sandy']['redis']['namespace'],
    sandy_cache_path: node['sandy']['cache_dir'],
    sandy_scratch_path: node['sandy']['scratch_dir'],
    processing_number_of_cpus: node['cpu']['total'],
    path: env_path
  } })
end

execute 'generate_init_scripts' do
  command "/opt/chef/embedded/bin/foreman export runit /etc/service -a sandy -u #{node['sandy']['account']}"
  cwd node['sandy']['install_dir']
  action :nothing
  subscribes :run, "template[#{node['sandy']['install_dir']}/.env]", :immediately
end