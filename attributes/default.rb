default['sandy']['environment'] = "development"
default['sandy']['data_bag'] = 'sandy-test'

#Path configuration
default['sandy']['home'] = '/www/sandy'

#Rails configuration
default['sandy']['scratch_dir'] = "/tmp/scratch"
default['sandy']['shared_dir'] = "/tmp/shared"

default['sandy']['worker']['user']
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
  'version' => 'ruby-2.1.1',
  'package' => 'gina-ruby-21'
}