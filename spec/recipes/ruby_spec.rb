require 'spec_helper'

describe 'sandy::ruby' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new.converge(described_recipe)
  end

  it 'includes yum-gina' do
    expect(chef_run).to include_recipe('yum-gina')
  end

  it 'includes chruby' do
    expect(chef_run).to include_recipe('chruby')
  end
end
