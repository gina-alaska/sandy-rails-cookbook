default['sandy']['version'] = "1.0.0-1.el6"
default['sandy']['environment'] = "development"
default['sandy']['data_bag'] = 'sandy-test'

#Path configuration
default['sandy']['home'] = '/opt/sandy'

#Rails configuration
default['sandy']['scratch_dir'] = "/tmp/scratch"
default['sandy']['shared_dir'] = "/tmp/shared"

default['sandy']['worker']['data_bag'] = 'sandy-utils-production'
default['sandy']['worker']['home'] = '/opt/processing-scripts'
default['sandy']['worker']['repo'] = 'git://github.com/gina-alaska/sandy-utils'
default['sandy']['worker']['revision'] = 'master'
default['sandy']['worker']['deploy_action'] = 'deploy'
default['sandy']['worker']['queues'] = []

default['sandy']['database']['hostname'] = "localhost"

default['sandy']['redis']['url'] = 'redis://localhost:6379'
default['sandy']['redis']['namespace'] = 'sandy'

default['sandy']['puma_port'] = '5000'

default['sandy']['ruby'] = {
  'version' => 'ruby-2.2.0',
  'package' => 'gina-ruby'
}
default['sandy']['storage']['actions'] = [:mount, :enable]
