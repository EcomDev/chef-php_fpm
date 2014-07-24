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

describe 'php_fpm::default' do
  include SpecHelper

  let(:chef_run) do
    chef_run_proxy.instance do |node|
      stub_php_vars(node)
    end.converge(described_recipe)
  end

  context 'In all OS versions it' do
    it 'raises an exception when php version is not found' do
      chef_run_proxy.block(:initialize, true) do |node|
        node.set['php']['major_version'] = '99.99'
      end
      expect { chef_run }.to raise_error('PHP version 99.99 is unknown')
    end

    it 'sets version of php to 5.1.0' do
      expect(chef_run.node['php']['version']).to eq('5.1.0')
    end

    it 'sets checksum of php to test1' do
      expect(chef_run.node['php']['checksum']).to eq('test1')
    end

    it 'sets install method of php to source' do
      expect(chef_run.node['php']['install_method']).to eq('source')
    end

    it 'sets change php extension directory to version based' do
      expect(chef_run.node['php']['ext_conf_dir']).to end_with('5.1.0')
      expect(chef_run.node['php']['ext_dir']).to eq(File.join(chef_run.node['php']['prefix_dir'], 'lib', 'php', 'modules', '5.1.0'))
      expect(chef_run.node['php']['configure_options']).to include('--with-config-file-scan-dir=' + chef_run.node['php']['ext_conf_dir'])
    end


    it 'includes php recipe for installing it from source' do
      expect(chef_run).to include_recipe('php::default')
    end
  end
  platform({family: :debian}, true) do |name, version|
    context 'In ' + name + ' ' + version +  ' systems it' do
      before (:each) do
        chef_run_proxy.options(platform: name, version: version)
      end

      it 'includes apt recipe to auto-update' do
        expect(chef_run).to include_recipe('apt::default')
      end

      it 'sets apt compiletime attribute to true' do
        expect(chef_run.node['apt']['compiletime']).to eq(true)
      end

      it 'sets apt compile_time_update attribute to true' do
        expect(chef_run.node['apt']['compile_time_update']).to eq(true)
      end
    end
  end

  platform({family: :rhel}, true)  do |name, version|
    context 'In ' + name + ' ' + version +  ' systems it' do
      before (:each) do
        chef_run_proxy.options(platform: name, version: version)
      end

      it 'replaces php prefix path' do
        expect(chef_run.node['php']['prefix_dir']).to eq('/usr')
      end

      it 'replaces php prefix path in php configure options' do
        expect(chef_run.node['php']['prefix_dir']).to eq('/usr')
      end
    end
  end
end