# include_recipe 'runit'
include_recipe 'sandy::application'

# concurrency = node['sandy']['worker']['concurrency'] || node['cpu']['total']
#
# template "#{node['sandy']['install_dir']}/config/sidekiq.yml" do
#   source "sidekiq.yml.erb"
#   owner node['sandy']['account']
#   group node['sandy']['account']
#   mode 0644
#   variables({
#     concurrency: concurrency,
#     queues: node['sandy']['worker']['queues']
#   })
#   notifies :restart, "runit_service[sidekiq]"
# end
#
#Set path information
directory node['sandy']['worker']['scripts-path'] do
  owner node['sandy']['account']
  group node['sandy']['account']
end

git node['sandy']['worker']['scripts-path'] do
  repository node['sandy']['worker']['scripts-git-repo']
  revision node['sandy']['worker']['scripts-git-revision']
  action node['sandy']['worker']['scripts-git-action']
end

execute 'bundle-install' do
  command "chruby-exec #{node['sandy']['ruby']['version']} -- bundle install --deployment --path /home/#{node['sandy']['account']}/.bundle"
  cwd node['sandy']['worker']['scripts-path']
  user node['sandy']['account']
  group node['sandy']['account']
  action :nothing
  subscribes :run, "git[#{node['sandy']['worker']['scripts-path']}]", :delayed
end

service 'sandy-default-worker-1' do
  action [:start, :enable]
  subscribes :restart, "template[#{node['sandy']['install_dir']}/.env]"
end

service 'sandy-worker-1' do
  action [:start, :enable]
  subscribes :restart, "template[#{node['sandy']['install_dir']}/.env]"
  not_if { node['sandy']['queue'].nil? }
end



# runit_service 'sidekiq' do
#   log true
#   default_logger true
#   env({
#     "PATH" => "/usr/bin:/bin:#{node['sandy']['worker']['scripts-path']}/bin",
#     "SVWAIT" => "15",
#     "SANDY_SCRATCH_PATH" => node['sandy']['secrets']['scratch_path'],
#     "SANDY_SHARED_PATH" => node['sandy']['secrets']['shared_path'],
#     "PROCESSING_NUMBER_OF_CPUS" => "#{node['cpu']['total']}"
#   })
#   options({
#     user: node['sandy']['account'],
#     rubyversion: node['sandy']['ruby']['version'],
#     app_dir: "#{node['sandy']['install_dir']}",
#     environment: node['sandy']['environment'],
#     pidfile: "#{node['sandy']['install_dir']}/tmp/sidekiq.pid"
#   })
# end
