require 'spec_helper'

describe 'sandy::database' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
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

  it 'should update ca-certificates' do
    expect(chef_run).to install_yum_package('ca-certificates')
  end

  it 'should include yum-epel' do
    expect(chef_run).to include_recipe('yum-epel')
  end

  it 'should include posgresql::server' do
    expect(chef_run).to include_recipe('postgresql::server')
  end

  it 'should include database::postgresql' do
    expect(chef_run).to include_recipe('database::postgresql')
  end

  it 'should include postgresql::ruby' do
    expect(chef_run).to include_recipe('postgresql::ruby')
  end

  it 'should include chef-vault' do
    expect(chef_run).to include_recipe('chef-vault')
  end

  it 'should create the sandy database' do
    expect(chef_run).to create_postgresql_database('sandy_production')
  end

  it 'should create the sandy database user' do
    expect(chef_run).to create_postgresql_database_user('sandy')
  end

  it 'should grant all priveleges to the sandy user on the sandy db' do
    expect(chef_run).to grant_postgresql_database_user('sandy')
  end
end