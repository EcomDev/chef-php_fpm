require 'spec_helper'

describe 'php_fpm::default' do
  include SpecHelper

  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      stub_php_vars(node)
      stub_include
    end
  end

  context 'In all OS versions it' do


    it 'raises an exception when php version is not found' do
      chef_run.node.set['php']['version'] = '99.99'
      expect { converged }.to raise_error('PHP version is unknown')
    end

    it 'sets version of php to 5.1.0' do
      expect(converged.node['php']['version']).to eq('5.1.0')
    end

    it 'sets checksum of php to test1' do
      expect(converged.node['php']['checksum']).to eq('test1')
    end

    it 'sets install method of php to source' do
      expect(converged.node['php']['install_method']).to eq('source')
    end

    it 'includes php recipe for installing it from source' do
      expect(converged).to include_recipe('php::default')
    end
  end

end