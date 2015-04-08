require 'spec_helper'

describe 'sandy::default' do
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


  it 'should include the database recipe' do
    expect(chef_run).to include_recipe('sandy::database')
  end
  it 'should include the redis recipe' do
    expect(chef_run).to include_recipe('sandy::redis')
  end
  it 'should include the web recipe' do
    expect(chef_run).to include_recipe('sandy::web')
  end
  it 'should include the worker recipe' do
    expect(chef_run).to include_recipe('sandy::worker')
  end

end
