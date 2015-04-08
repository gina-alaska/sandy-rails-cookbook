include_recipe "sandy::application"

service 'sandy-web-1' do
  #reload_command
  #restart_command
  action [:start, :enable]
  subscribes :restart, "template[#{node['sandy']['install_dir']}/.env]"
end

include_recipe "sandy::nginx"
