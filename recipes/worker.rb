include_recipe 'runit'
include_recipe 'sandy::application'

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


