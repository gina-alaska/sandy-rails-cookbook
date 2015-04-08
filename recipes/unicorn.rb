# include_recipe "runit"
#
# app_name = "sandy"
# user node[app_name]['account']
#
# directory node['unicorn']['listen'] do
#   user node[app_name]['account']
#   group node[app_name]['account']
#   recursive true
#   action :create
# end

#TODO:  Generate init scripts from procfile when package install happens
#TODO:  Restart on update of init scripts

# unicorn_config node['unicorn']['config_path'] do
#   # preload_app node[app_name]['unicorn']['preload_app']
#   preload false
#   listen "#{node['unicorn']['listen']}/#{app_name}.socket" => {backlog: 1024}
#   pid node['unicorn']['pid']
#   stderr_path node['unicorn']['stderr']
#   stdout_path node['unicorn']['stdout']
#   worker_timeout node['unicorn']['worker_timeout']
#   worker_processes [node['cpu']['total'].to_i * 4, 8].min
#   working_directory node['unicorn']['deploy_path']
#   before_fork node['unicorn']['before_fork']
#   after_fork node['unicorn']['after_fork']
# end
#
# runit_service 'unicorn' do
#   restart_command '2'
#   log true
#   default_logger true
#   env({
#     "SECRET_KEY_BASE" => node['sandy']['rails']['secret_key_base'],
#     "SANDY_SCRATCH_PATH" => node['sandy']['scratch_dir'],
#     "SANDY_SHARED_PATH" => node['sandy']['shared_dir']
#   })
#   options({
#     app: "#{node['sandy']['installation_dir']}",
#     user: node['sandy']['account'],
#     unicorn_config_path: node['unicorn']['config_path'],
#     pid_dir: "#{node['sandy']['installation_dir']}/tmp/unicorn.pid"
#   })
# end
