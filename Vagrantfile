# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "sandy-development"

  config.vm.box = "opscode_centos-6.4_provisionerless"
  config.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
  end

  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  #Force ip4/6 requests to be made seperatly
  config.vm.provision :shell, inline: "if [ ! $(grep single-request-reopen /etc/sysconfig/network) ]; then echo RES_OPTIONS=single-request-reopen >> /etc/sysconfig/network && service network restart; fi"

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      'chruby' => {
        'default' => 'embedded'
      },
      'unicorn' => {
        'listen' => '/var/run/unicorn/',
        'pid' => '/www/sandy/tmp/pids/unicorn_sandy.pid',
        'stderr_path' => '/www/sandy/log/unicorn.stderr.log',
        'stdout_path' => '/www/sandy/log/unicorn.stdout.log'
      },
      "sandy" => {
        'account' => "vagrant",
        'environment' => "development",
        'database' => {
          'hostname' => '127.0.0.1',
          'database' => 'sandy_dev',
          'username' => 'sandy_dev',
          'password' => 'sandy_dev_postgres',
          'search_path' => 'sandy_dev,public'
        },
        'paths' => {
          'config' => "/www/sandy/config",
          'initializers' => "/www/sandy/config/initializers"
        },
        'database_setup' => true
      },
      'postgresql' => {
        'password' => {
          'postgres' => "fasdfasdfasdfasdf"
        },
        'config' => {
          'listen_addresses' => '*'
        }
      }
    }

    chef.run_list = [
      "recipe[sandy::default]"
    ]
  end
end
