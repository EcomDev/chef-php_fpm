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

describe 'php_fpm::_test_pool_create' do
  include SpecHelper

  before (:each) { allow_recipe('php_fpm::fpm') }

  let(:chef_run) do
    chef_run_proxy.instance(step_into: 'php_fpm_pool') do |node|
      node.set[:_php_fpm_test][:pool] = pool_name
    end.converge(described_recipe)
  end

  def test_params(&block)
    chef_run_proxy.before(:converge, false) do |runner|
      if block.arity == 1
        block.call(runner.node.set[:_php_fpm_test])
      else
        block.call(runner.node.set[:_php_fpm_test], runner.node)
      end
    end
  end

  let (:node) { chef_run.node }

  context 'On all OS it' do

    let (:pool_name) { 'test' }

    it 'creates a new fpm pool test' do
      expect(chef_run).to create_php_fpm_pool('test')
    end

    it 'includes php_fpm::fpm recipe' do
      expect(chef_run).to include_recipe('php_fpm::fpm')
    end


    it 'creates php fpm config file with expected content matchers' do
      expect(chef_run).to render_file(File.join(node['php']['fpm']['conf_dir'], 'php-fpm.conf'))
                           .with_content(
                               contain_line('pid = ' + File.join(node['php']['fpm']['run_dir'], node['php']['fpm']['service'] + '.pid'))
                               .and contain_line('log_level = ' + node['php']['fpm']['log_level'])
                               .and contain_line('error_log = ' + node['php']['fpm']['error_log'])
                               .and contain_line('emergency_restart_threshold = ' + node['php']['fpm']['emergency_restart_threshold'])
                               .and contain_line('emergency_restart_interval = ' + node['php']['fpm']['emergency_restart_interval'])
                               .and contain_line('process_control_timeout = ' + node['php']['fpm']['process_control_timeout'])
                               .and contain_line('daemonize = ' + node['php']['fpm']['daemonize'])
                               .and contain_line('include=' + node['php']['fpm']['pool_dir'] + '/*.conf')
                           )
    end

    it 'creates php fpm pool config file with default values' do
      expect(chef_run).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(
                               contain_line('[test]')
                               .and contain_line('user = ' + node['php']['fpm']['default']['user'])
                               .and contain_line('group = ' + node['php']['fpm']['default']['group'])
                               .and contain_line('listen = ' + node['php']['fpm']['run_dir'] + '/test.php-fpm-sock')
                               .and contain_line('listen.owner = ' + node['php']['fpm']['default']['socket_user'])
                               .and contain_line('listen.group = ' + node['php']['fpm']['default']['socket_group'])
                               .and contain_line('listen.mode = ' + node['php']['fpm']['default']['socket_mode'])
                               .and contain_line('pm = ' + node['php']['fpm']['default']['pm'])
                               .and contain_line('pm.max_children = ' + node['php']['fpm']['default']['max_children'])
                               .and contain_line('pm.start_servers = ' + node['php']['fpm']['default']['start_servers'])
                               .and contain_line('pm.min_spare_servers = ' + node['php']['fpm']['default']['min_spare_servers'])
                               .and contain_line('pm.max_spare_servers = ' + node['php']['fpm']['default']['max_spare_servers'])
                               .and contain_line('pm.max_requests = ' + node['php']['fpm']['default']['max_requests'])
                               .and contain_line('pm.status_path = ' + node['php']['fpm']['default']['status_path'])
                               .and contain_line('ping.path = ' + node['php']['fpm']['default']['ping_path'])
                               .and contain_line('ping.response = ' + node['php']['fpm']['default']['ping_response'])
                               .and contain_line('rlimit_files = ' + node['php']['fpm']['default']['rlimit_files'])
                               .and contain_line('rlimit_core = ' + node['php']['fpm']['default']['rlimit_core'])
                               .and contain_line('request_slowlog_timeout = ' + node['php']['fpm']['default']['request_slowlog_timeout'])
                               .and contain_line('slowlog = ' + File.join(node['php']['fpm']['log_dir'], node['php']['fpm']['default']['slowlog']))
                               .and contain_line('catch_workers_output = ' + node['php']['fpm']['default']['catch_workers_output'])
                           )
    end

    it 'creates env variable statements in pool config' do
      test_params do |params|
        params.env['MAGE_IS_DEVELOPER_MODE'] = '1'
      end
      expect(chef_run).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(
                               contain_line('env[MAGE_IS_DEVELOPER_MODE] = 1')
                           )
    end

    it 'creates php_flag variable statements in pool config' do
      test_params do |params|
        params.php_flag.memory_limit = '512m'
      end
      expect(chef_run).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(
                               contain_line('php_flag[memory_limit] = 512m')
                           )
    end

    it 'creates php_flag variable statements in pool config' do
      test_params do |params|
        params.php_value.memory_limit = '512m'
      end
      expect(chef_run).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(
                               contain_line('php_value[memory_limit] = 512m')
                           )
    end

    it 'creates php_admin_flag variable statements in pool config' do
      test_params do |params|
        params.php_admin_flag.memory_limit = '512m'
      end
      expect(chef_run).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(
                               contain_line('php_admin_flag[memory_limit] = 512m')
                           )
    end

    it 'creates php_admin_value variable statements in pool config' do
      test_params do |params|
        params.php_admin_value.memory_limit = '512m'
      end
      expect(chef_run).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(
                               contain_line('php_admin_value[memory_limit] = 512m')
                           )
    end

    it 'creates a pool for tpc ip listen' do
      test_params do |params|
        params.socket = false
        params.port = '9999'
      end
      expect(chef_run).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(contain_line('listen = 127.0.0.1:9999'))
    end

    it 'limits allowed ip addresses' do
      test_params do |params|
        params.socket = false
        params.allowed_ip = %w(127.0.0.1 33.33.33.1)
      end
      expect(chef_run).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(contain_line('listen.allowed_clients = 127.0.0.1,33.33.33.1'))
    end

    it 'allows to set backlog value' do
      test_params do |params|
        params.queue_size = 100
      end
      expect(chef_run).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(contain_line('listen.backlog = 100'))
    end

    it 'do not restart fpm service when fpm config is changed and no pools have been added before' do
      chef_run_proxy.block(:converge, false) do |runner|
        stub_dir_glob(File.join(runner.node['php']['fpm']['pool_dir'], '*.conf'), [])
      end
      template = chef_run.template(File.join(node['php']['fpm']['conf_dir'], 'php-fpm.conf'))
      expect(template).not_to notify('service[' + node['php']['fpm']['service'] + ']').to(:restart).immediately
    end

    it 'restarts fpm service if pools have been added before' do
      chef_run_proxy.block(:converge) do |runner|
        stub_dir_glob(File.join(runner.node['php']['fpm']['pool_dir'], '*.conf'), [File.join(runner.node['php']['fpm']['pool_dir'], 'other.conf')])
      end
      template = chef_run.template(File.join(node['php']['fpm']['conf_dir'], 'php-fpm.conf'))
      expect(template).to notify('service[' + node['php']['fpm']['service'] + ']').to(:restart).immediately
    end

    it 'starts fpm service if pool config was updated and no pools have been started' do
      chef_run_proxy.block(:converge) do |runner|
        stub_dir_glob(File.join(runner.node['php']['fpm']['pool_dir'], '*.conf'), [])
      end

      template = chef_run.template(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
      expect(template).to notify('service[' + node['php']['fpm']['service'] + ']').to(:start).immediately
    end

    it 'reloads fpm service if pool config was updated' do
      chef_run_proxy.block(:converge) do |runner|
        stub_dir_glob(File.join(runner.node['php']['fpm']['pool_dir'], '*.conf'), [File.join(runner.node['php']['fpm']['pool_dir'], 'other.conf')])
      end
      template = chef_run.template(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
      expect(template).to notify('service[' + node['php']['fpm']['service'] + ']').to(:reload).immediately
    end

    it 'stores resource options into shared data' do
      chef_run
      expect(EcomDev::SharedData.get(:resource, :php_fpm_pool, :test)).to include(
                                                                              name: 'test',
                                                                              ip: '127.0.0.1',
                                                                              port: '9000',
                                                                              socket: true
                                                                          )
    end

    it 'stores information about added resource into shared data' do
      chef_run
      hash = EcomDev::SharedData.get(:resource, :fpm, :test)
      expect(hash).to include(socket_path: node['php']['fpm']['run_dir'] + '/test.php-fpm-sock')
      expect(hash.keys.map(&:to_sym)).to contain_exactly(:socket_path)
    end

    it 'stores information about added resource into shared data with tcp options' do
      test_params do |params|
        params.socket = false
      end
      chef_run
      hash = EcomDev::SharedData.get(:resource, :fpm, :test)
      expect(hash).to include(ip: '127.0.0.1', port: '9000')
      expect(hash.keys.map(&:to_sym)).to contain_exactly(:ip, :port)
    end
  end
end