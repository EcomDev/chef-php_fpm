#
# PHP-FPM Cookbook - PHP-FPM Chef Cookbook to allow building easily vagrant
# environment
# Copyright (C) 2014 Ivan Chepurnyi <ivan.chepurnyi@ecomdev.org>, EcomDev B.V.
#
# This file is part of PHP-FPM Cookbook.
#
# PHP-FPM Cookbook is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# PHP-FPM Cookbook is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with PHP-FPM Cookbook.  If not, see <http://www.gnu.org/licenses/>.
#
require 'spec_helper'

describe 'php_fpm::_test_pool_delete' do
  include SpecHelper

  before (:each) { allow_recipe('php_fpm::fpm') }

  let(:chef_run) do
    chef_run_proxy.instance(step_into: 'php_fpm_pool') do |node|
      node.set[:_php_fpm_test][:pool] = pool_name
    end.converge(described_recipe)
  end

  let (:node) { chef_run.node }

  context 'On all OS it' do
    let (:pool_name) { 'test' }

    it 'creates a new fpm pool test' do
      expect(chef_run).to delete_php_fpm_pool('test')
    end

    it 'includes php_fpm::fpm recipe' do
      expect(chef_run).to include_recipe('php_fpm::fpm')
    end


    it 'it deletes php fpm pool config file' do
      expect(chef_run).to delete_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
    end

    it 'reloads fpm service if pools have been added before' do
      chef_run_proxy.block(:converge, false) do |runner|
        stub_dir_glob(File.join(runner.node['php']['fpm']['pool_dir'], '*.conf'), [File.join(runner.node['php']['fpm']['pool_dir'], 'other.conf')])
      end
      file = chef_run.file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
      expect(file).to notify('service[' + node['php']['fpm']['service'] + ']').to(:reload).immediately
    end

    it 'stop fpm service if pool config was updated and no pools have been started' do
      chef_run_proxy.block(:converge, false) do |runner|
        stub_dir_glob(File.join(runner.node['php']['fpm']['pool_dir'], '*.conf'), [File.join(runner.node['php']['fpm']['pool_dir'], 'test.conf')])
      end

      file = chef_run.file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
      expect(file).to notify('service[' + node['php']['fpm']['service'] + ']').to(:stop).immediately
    end
  end
end