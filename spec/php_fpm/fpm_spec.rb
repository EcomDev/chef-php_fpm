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

describe 'php_fpm::fpm' do
  include SpecHelper

  let (:chef_run) do
    chef_run_proxy.instance do |node|
      stub_php_vars(node)
    end.converge(described_recipe)
  end

  context 'On all OS it' do
    it 'includes php_fpm::default recipe' do
      expect(chef_run).to include_recipe('php_fpm::default')
    end
  end

  platform(:debian, :ubuntu, :freebsd, true) do |name, version|
    context 'In ' + name + ' ' + version + ' with default parameters it' do
      before(:each) {chef_run_proxy.options(platform: name, version: version)}

      it 'sets php-fpm configuration directory' do
        expect(chef_run.node['php']['fpm']['conf_dir']).to eq('/etc/php5/fpm')
      end

      it 'sets php-fpm pool directory' do
        expect(chef_run.node['php']['fpm']['pool_dir']).to eq('/etc/php5/fpm/pool.d')
      end

      it 'sets php-fpm log directory' do
        expect(chef_run.node['php']['fpm']['log_dir']).to eq('/var/log/php5-fpm')
      end

      it 'sets php-fpm socket path' do
        expect(chef_run.node['php']['fpm']['run_dir']).to eq('/var/run')
      end

      it 'sets php-fpm logrotate config file' do
        expect(chef_run.node['php']['fpm']['logrotate_file']).to eq('/etc/logrotate.d/php5-fpm')
      end

      it 'sets php-fpm service name' do
        expect(chef_run.node['php']['fpm']['service']).to eq('php5-fpm')
      end

      it 'sets php-fpm pid file location' do
        expect(chef_run.node['php']['fpm']['pid']).to eq('/var/run/php5-fpm.pid')
      end

      it 'sets php-fpm error log location' do
        expect(chef_run.node['php']['fpm']['error_log']).to eq('/var/log/php5-fpm/fpm-master.log')
      end
    end
  end

  platform({family: [:rhel, :fedora]}, true) do |name, version|
    context 'In ' + name + ' ' + version + ' with default parameters it' do
      before(:each) {chef_run_proxy.options(platform: name, version: version)}

      it 'sets php-fpm configuration directory' do
        expect(chef_run.node['php']['fpm']['conf_dir']).to eq('/etc')
      end

      it 'sets php-fpm pool directory' do
        expect(chef_run.node['php']['fpm']['pool_dir']).to eq('/etc/php-fpm.d')
      end

      it 'sets php-fpm log directory' do
        expect(chef_run.node['php']['fpm']['log_dir']).to eq('/var/log/php-fpm')
      end

      it 'sets php-fpm socket path' do
        expect(chef_run.node['php']['fpm']['run_dir']).to eq('/var/run/php-fpm')
      end

      it 'sets php-fpm logrotate config file' do
        expect(chef_run.node['php']['fpm']['logrotate_file']).to eq('/etc/logrotate.d/php-fpm')
      end

      it 'sets php-fpm service name' do
        expect(chef_run.node['php']['fpm']['service']).to eq('php-fpm')
      end

      it 'sets php-fpm pid file location' do
        expect(chef_run.node['php']['fpm']['pid']).to eq('/var/run/php-fpm/php-fpm.pid')
      end

      it 'sets php-fpm error log location' do
        expect(chef_run.node['php']['fpm']['error_log']).to eq('/var/log/php-fpm/fpm-master.log')
      end
    end
  end

  platform({family: [:debian, :rhel]}, true) do |name, version|
    context 'On ' + name + ' ' + version + ' it' do
      before(:each) {chef_run_proxy.options(platform: name, version: version)}

      let (:config) do
        is_redhat = ['redhat', 'centos'].include?(name)
        return {
          conf_dir: is_redhat ? '/etc' : '/etc/php5/fpm',
          pool_dir: is_redhat ? '/etc/php-fpm.d' : '/etc/php5/fpm/pool.d',
          log_dir: is_redhat ? '/var/log/php-fpm' : '/var/log/php5-fpm',
          run_dir: is_redhat ? '/var/run/php-fpm' : '/var/run',
        }
      end

      it 'creates a configuration file for php-fpm daemon' do
        expect(chef_run).to render_file('/etc/init.d/' + chef_run.node['php']['fpm']['service'])
                            .with_content('php_fpm_PID=' + chef_run.node['php']['fpm']['pid'])
      end

      it 'enables a php-fpm service ' do
        expect(chef_run).to enable_service(chef_run.node['php']['fpm']['service'])
      end

      it 'creates a log rotate daemon file for rotating php fpm logs' do
        expect(chef_run).to render_file(chef_run.node['php']['fpm']['logrotate_file'])
                             .with_content(chef_run.node['php']['fpm']['log_dir'] + '/*.log')
      end

      it 'removes default fpm-code pool if fpm_remove_default_pool equals to true' do
        chef_run_proxy.block(:converge) { |runner| runner.node.set['php']['fpm']['disable_default_pool'] = true }
        expect(chef_run).to delete_file(chef_run.node['php']['fpm']['pool_dir'] + '/www.conf')
      end

      it 'does not remove default fpm-code pool if fpm_remove_default_pool equals to false' do
        chef_run_proxy.block(:converge) { |runner| runner.node.set['php']['fpm']['disable_default_pool'] = false }
        expect(chef_run).not_to delete_file(chef_run.node['php']['fpm']['pool_dir'] + '/www.conf')
      end

      it 'removes default fpm-code pool' do
        expect(chef_run).to delete_file(chef_run.node['php']['fpm']['pool_dir'] + '/www.conf')
      end

      it 'creates php-fpm config directory if it does not exist' do
        stub_dir_existence(config, false)
        expect(chef_run).to create_directory(config[:conf_dir])
                          .with(user: 'root', group: 'root', mode: 00755, recursive: true)
      end

      it 'creates php-fpm pool directory if it does not exist' do
        stub_dir_existence(config, false)
        expect(chef_run).to create_directory(config[:pool_dir])
                            .with(user: 'root', group: 'root', mode: 00755, recursive: true)
      end

      it 'creates php-fpm log directory if it does not exist' do
        stub_dir_existence(config, false)
        expect(chef_run).to create_directory(config[:log_dir])
                            .with(user: 'root', group: 'root', mode: 01733, recursive: true)
      end

      it 'create php-fpm socket path if it does not exists' do
        stub_dir_existence(config, false)
        expect(chef_run).to create_directory(config[:run_dir])
                            .with(user: 'root', group: 'root', mode: 00755, recursive: true)
      end

      it 'does not create php-fpm config directory if it exists' do
        stub_dir_existence(config, true)
        expect(chef_run).not_to create_directory(config[:conf_dir])
                            .with(user: 'root', group: 'root', mode: 00755, recursive: true)
      end

      it 'does not create php-fpm pool directory if it exists' do
        stub_dir_existence(config, true)
        expect(chef_run).not_to create_directory(config[:pool_dir])
                            .with(user: 'root', group: 'root', mode: 00755, recursive: true)
      end

      it 'does not create php-fpm log directory if it exists' do
        stub_dir_existence(config, true)
        expect(chef_run).not_to create_directory(config[:log_dir])
                            .with(user: 'root', group: 'root', mode: 01733, recursive: true)
      end

      it 'does not create php-fpm socket path if it exists' do
        stub_dir_existence(config, true)
        expect(chef_run).not_to create_directory(chef_run.node['php']['fpm']['run_dir'])
                            .with(user: 'root', group: 'root', mode: 00755, recursive: true)
      end
    end
  end
end