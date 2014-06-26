require 'spec_helper'

describe 'php_fpm::_test_pool_delete' do
  include SpecHelper

  let(:chef_run) do
    ChefSpec::Runner.new(step_into: 'php_fpm_pool') do |node|
      stub_include
      node.set[:_php_fpm_test][:pool] = pool_name
    end
  end

  let (:test_params) { chef_run.node.set[:_php_fpm_test] }

  let (:node) { chef_run.node }

  context 'On all OS it' do
    let (:pool_name) { 'test' }

    it 'creates a new fpm pool test' do
      expect(converged).to delete_php_fpm_pool('test')
    end

    it 'includes php_fpm::fpm recipe' do
      expect(converged).to include_recipe('php_fpm::fpm')
    end


    it 'it deletes php fpm pool config file' do
      expect(converged).to delete_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
    end
  end
end