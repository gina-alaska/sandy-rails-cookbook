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
  notifies :create, "template[#{node['sandy']['install_dir']}/sandy/.env]", :immediately
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

template '/etc/profile.d/sandy_path.sh' do
  source 'sandy_path.sh.erb'
  mode 0644
  variables({
    path: node['sandy']['install_dir']
    })
end

template "#{node['sandy']['install_dir']}/sandy/.env" do
  source 'foreman_env.erb'
  variables({ env: {
    rails_env: node['sandy']['environment'],
    rails_database: "sandy-#{node['sandy']['environment']}",
    rails_database_username: 'sandy',
    rails_database_password: database_config['passwords']['sandy'],
    rails_database_host: database_host['ipaddress'],
    secret_key_base: node['sandy']['rails']['secret_key_base'],
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
    path: env_path,
    port: node['sandy']['puma_port']
  } })
end

runit_template_path = ::File.join(Chef::Config[:file_cache_path], 'sandy-runit-template')

directory runit_template_path

cookbook_file ::File.join(runit_template_path, "run.erb") do
  source 'foreman-run.erb'
end

foreman_cmd = [
  '/opt/chef/embedded/bin/foreman',
  'export',
  'runit',
  '/etc/service',
  '-a sandy',
  "-u #{node['sandy']['account']}",
  "-t #{runit_template_path}"
].join(" ")

execute 'generate_init_scripts' do
  command foreman_cmd
  cwd "#{node['sandy']['install_dir']}/sandy"
  action :nothing
  subscribes :run, "template[#{node['sandy']['install_dir']}/sandy/.env]", :immediately
end