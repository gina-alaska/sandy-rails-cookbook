require 'spec_helper'

describe 'sandy::application' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new do |node, server|
      server.create_data_bag('sandy', {
        'influxdb' => {
          'users' => {
            'sandy' => {
              'password' => 'chef-spec-password'
            }
          }
        }
      })
    end
  end

  before do
    allow(ChefVault::Item).to receive(:load).
      with(:sandy, 'database').and_return({
        'passwords' => {
          'sandy' => 'chef-spec-password'
        }
      } )

    chef_run.converge(described_recipe)
  end

  it 'should include chef-vault' do
    expect(chef_run).to include_recipe('chef-vault')
  end

  it 'should add web user' do
    expect(chef_run).to create_user('webdev')
  end

  it 'should create database template' do
    expect(chef_run).to create_template('/opt/sandy/config/database.yml')
  end

  it 'should squish database attributes' do
    expect(chef_run).to run_ruby_block('squish-database-attributes')
  end

  it 'should create the influxdb initializer' do
    expect(chef_run).to create_template('/opt/sandy/config/initializers/influxdb-rails.rb')
  end

  it 'should create rails secrets config' do
    expect(chef_run).to create_template('/opt/sandy/config/secrets.yml')
  end

  it 'should create rails sidekiq initializer' do
    expect(chef_run).to create_template('/opt/sandy-config/initializers/sidekiq.rb')
  end
end