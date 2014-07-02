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
    ChefSpec::Runner.new(options)  do |node|
      stub_php_vars(node)
      stub_include
    end
  end

  context 'In all OS versions it' do
    let (:options) { Hash.new }

    it 'raises an exception when php version is not found' do
      chef_run.node.set['php']['major_version'] = '99.99'
      expect { converged }.to raise_error('PHP version 99.99 is unknown')
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

  SpecPlatforms.filtered(true, ['ubuntu', 'debian']).each do |platform, version|
    context 'In ' + platform + ' ' + version +  ' systems it' do
      let (:options) do
        { platform: platform, version: version }
      end

      it 'includes apt recipe to auto-update' do
        expect(converged).to include_recipe('apt::default')
      end

      it 'sets apt compiletime attribute to true' do
        expect(converged.node['apt']['compiletime']).to eq(true)
      end

      it 'sets apt compile_time_update attribute to true' do
        expect(converged.node['apt']['compile_time_update']).to eq(true)
      end
    end
  end

  SpecPlatforms.filtered(true, ['centos']).each do |platform, version|
    context 'In ' + platform + ' ' + version +  ' systems it' do
      let (:options) do
        { platform: platform, version: version }
      end

      it 'replaces php prefix path' do
        expect(converged.node['php']['prefix_dir']).to eq('/usr')
      end

      it 'replaces php prefix path in php configure options' do
        expect(converged.node['php']['prefix_dir']).to eq('/usr')
      end

      it 'sets apt compile_time_update attribute to true' do

      end
    end
  end
end