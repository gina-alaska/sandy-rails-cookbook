default['sandy']['account'] = "webdev"
default['sandy']['environment'] = "development"

#Path configuration
default['sandy']['install_dir'] = '/opt/sandy'
default['sandy']['application'] = {
  'name' => 'sandy',
  'version' => '0.0.1-1'
}

#Rails configuration
default['sandy']['rails']['secret_key_base'] = 'b4b8fefeb6fc52226822bf3e293b250733b73d82388822a32d477a04ba4ce956dc251e656b3182ae8b21dbedce3c7d406488d12d2f4d4eaf4db40e115de3c675'
default['sandy']['rails']['application_class_name'] = ''

default['sandy']['scratch_dir'] = "/tmp/scratch"
default['sandy']['shared_dir'] = "/tmp/shared"

default['sandy']['worker']['user']
default['sandy']['worker']['scripts-path'] = '/opt/processing-scripts'
default['sandy']['worker-log-dir'] = '/var/log/sidekiq'
default['sandy']['worker']['scripts-git-repo'] = 'git://github.com/gina-alaska/sandy-utils'
default['sandy']['worker']['scripts-git-revision'] = 'master'
default['sandy']['worker']['scripts-git-action'] = 'checkout'
default['sandy']['worker']['queue'] = nil

default['sandy']['database']['hostname'] = "localhost"

default['sandy']['redis']['url'] = 'redis://localhost:6379'
default['sandy']['redis']['namespace'] = 'sandy'