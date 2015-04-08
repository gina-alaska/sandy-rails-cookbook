include_recipe 'runit'
include_recipe "sandy::application"

runit_service "sandy-web-1" do
  sv_templates false
  action [:start, :enable]
  subscribes :restart, "template[#{node['sandy']['install_dir']}/.env]"
end

include_recipe "sandy::nginx"
