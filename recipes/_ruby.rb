include_recipe "yum-gina"

ruby_package = "#{Chef::Config[:file_cache_path]}/gina-ruby-2.2.0-1.x68_64.rpm"

remote_file ruby_package do
  source "https://s3-us-west-2.amazonaws.com/gina-packages/gina-ruby-2.2.0-1.x86_64.rpm"
  notifies :run, 'package[install-ruby]', :immediately
end

package 'install-ruby' do
  package_name ruby_package
end

include_recipe 'chruby'

%w(libxml2 libxml2-devel libxslt libxslt-devel postgresql-libs).each do |pkg|
  package pkg
end

%w(bundle bundler ruby).each do |rb|
  link "/usr/bin/#{rb}" do
    to "/opt/rubies/#{node['sandy']['ruby']['version']}/bin/#{rb}"
  end
end
