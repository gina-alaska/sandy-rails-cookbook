include_recipe "chef-vault"

user node['sandy']['account']

packagecloud_repo "sdmacfarlane/demo" do
  type "rpm"
end

package node['sandy']['application']['name'] do
  version node['sandy']['application']['version']
  action :install
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
    redis_url: "redis://#{redis_master['ipaddress']}:6379",
    redis_namespace: node['sandy']['redis']['namespace'],
    sandy_cache_path: node['sandy']['cache_dir'],
    sandy_scratch_path: node['sandy']['scratch_dir'],
    processing_number_of_cpus: node['cpu']['total'],
    path: env_path
  } })
end

# db_master = search(:node, 'roles:sandy-database').first
# db_master = node if db_master.nil?
#
# template "#{node['sandy']['install_dir']}/config/database.yml" do
#   owner node['sandy']['account']
#   group node['sandy']['account']
#   mode 00644
#   variables({
#     environment: node['sandy']['environment'],
#     database: node['sandy']['database'],
#     hostname: db_master['ipaddress']
#   })
# end
#
# ruby_block "squish-database-attributes" do
#   block do
#     node.rm('sandy','database','password')
#   end
#   subscribes :create, "template[#{node['sandy']['install_dir']}/config/database.yml]"
# end
#
# influx_servers = search(:node, 'roles:sandy-influxdb').map(&:ipaddress)
# template "#{node['sandy']['install_dir']}/config/initializers/influxdb-rails.rb" do
#   owner node['sandy']['account']
#   group node['sandy']['account']
#   mode 00644
#   variables({
#     database: 'sandy-metrics',
#     username: 'sandy',
#     password: data_bag_item(:sandy, 'influxdb')['users']['sandy']['password'],
#     hosts: influx_servers
#   })
# end
#
# template "#{node['sandy']['install_dir']}/config/secrets.yml" do
#   owner node['sandy']['account']
#   group node['sandy']['account']
#   mode 00600
#   variables({
#     environment: node['sandy']['environment'],
#     secrets: node['sandy']['rails']['secrets']
#   })
# end
#
# redis_master = search(:node, 'roles:sandy-redis').first
# redis_master = node if redis_master.nil?
#
# template "#{node['sandy']['install_dir']}/config/initializers/sidekiq.rb" do
#   source "sidekiq_initializer.rb.erb"
#   owner node['sandy']['account']
#   group node['sandy']['account']
#   mode 0644
#   variables({
#     url: "redis://#{redis_master['ipaddress']}:6379",
#     namespace: node['sandy']['redis']['namespace']
#   })
# end
