directory node['sandy']['home'] do
  user 'processing'
  group 'processing'
  mode 0755
  recursive true
end

directory "#{node['sandy']['home']}/shared" do
  user 'processing'
  group 'processing'
  mode 755
  recursive true
end

directory "#{node['sandy']['home']}/shared/bundle" do
  user 'processing'
  group 'processing'
  mode 0755
  recursive true
end

app = chef_vault_item(:apps, node['sandy']['data_bag'])
database_host = search(:node, 'roles:sandy-database', filter_result: {'ip' => ['ipaddress']})
redis_master = search(:node, 'roles:sandy-redis', filter_result: {'ip' => ['ipaddress']})
influx_servers = search(:node, 'roles:sandy-influxdb', filter_result: {'ip' => ['ipaddress']})

database_host  = [{'ip' => node['ipaddress']}] if database_host.empty?
redis_master   = [{'ip' => node['ipaddress']}] if redis_master.empty?
influx_servers = [{'ip' => node['ipaddress']}] if influx_servers.empty?

template "#{node['sandy']['home']}/shared/.env.production" do
  source "env.erb"
  user 'processing'
  group 'processing'

  variables({env: app['env'].merge({
     rails_database_host: database_host.first['ip'],
     rails_database_password: app['passwords']['sandy'],
     influxdb_servers: influx_servers.map{|n| n['ip']},
     influxdb_password: app['passwords']['influxdb'],
     redis_url: "redis://#{redis_master.first['ip']}:6379",
     sidekiq_queue: node['sandy']['worker']['queue'],
     sandy_shared_path: node['sandy']['shared_dir'],
     sandy_scratch_path: node['sandy']['scratch_dir'],
     path: "$PATH:#{node['sandy']['worker']['home']}/current/bin"
   })
  })
end

template "#{node['sandy']['home']}/shared/sidekiq.yml" do
  source 'sidekiq.yml.erb'
  user 'processing'
  group 'processing'

  variables({queues: node['sandy']['worker']['queues']})
end

deploy_revision node['sandy']['home'] do
  repo app['repository']
  revision app['revision']
  user 'processing'
  group 'processing'
  migrate false
  migration_command 'bundle exec rake db:migrate'
  environment 'RAILS_ENV' => 'production'
  action node['sandy']['deploy_action'] || 'deploy'

  symlink_before_migrate({
    '.env.production' => '.env',
    'tmp' => 'tmp',
    'sidekiq.yml' => 'config/sidekiq.yml'
  })

  before_migrate do
    %w(pids log system public tmp).each do |dir|
      directory "#{node['sandy']['home']}/shared/#{dir}" do
        mode 0755
        recursive true
      end
    end

    execute 'bundle install' do
      cwd release_path
      user 'processing'
      group 'processing'
      command "bundle install --without test development --path=#{node['sandy']['home']}/shared/bundle"
      environment({"BUNDLE_BUILD__PG" => "--with-pg_config=/usr/pgsql-#{node['postgresql']['version']}/bin/pg_config"})
    end
  end

  before_restart do
    execute 'assets:precompile' do
      user 'processing'
      group 'processing'
      environment 'RAILS_ENV' => 'production'
      cwd release_path
      command 'bundle exec rake assets:precompile'
      only_if { node['sandy']['precompile_assets'] }
    end
  end

  after_restart do
    execute 'chown-release_path-assets' do
      command "chown -R processing:processing #{release_path}/public/assets"
      user 'root'
      action :run
      only_if { ::File.exists? "#{release_path}/public/assets"}
    end
  end
end