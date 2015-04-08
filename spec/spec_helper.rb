require 'chefspec'
require 'chefspec/berkshelf'
require 'chef-vault'

RSpec::configure do |config|
  # Specify the operating platform to mock Ohai data from (default: nil)
  config.platform = 'centos'

  # Specify the operating version to mock Ohai data from (default: nil)
  config.version = '6.5'
end


at_exit { ChefSpec::Coverage.report! }