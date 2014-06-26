require 'spec_helper'

describe 'php_fpm::_test_pool_create' do
  include SpecHelper

  let(:chef_run) do
    ChefSpec::Runner.new(step_into: 'php_fpm_pool') do |node|
      stub_include(['php_fpm::fpm'])
      node.set[:_php_fpm_test][:pool] = pool_name
    end
  end

  let (:test_params) { chef_run.node.set[:_php_fpm_test] }

  let (:node) { chef_run.node }

  context 'On all OS it' do
    let (:pool_name) { 'test' }

    it 'creates a new fpm pool test' do
      expect(converged).to create_php_fpm_pool('test')
    end

    it 'includes php_fpm::fpm recipe' do
      expect(converged).to include_recipe('php_fpm::fpm')
    end


    it 'creates php fpm config file with expected content matchers' do
      expect(converged).to render_file(File.join(node['php']['fpm']['conf_dir'], 'php-fpm.conf'))
                           .with_content(
                               line_starts_with('pid = ' + File.join(node['php']['fpm']['run_dir'], node['php']['fpm']['service'] + '.pid'))
                               .and line_starts_with('log_level = ' + node['php']['fpm']['log_level'])
                               .and line_starts_with('error_log = ' + node['php']['fpm']['error_log'])
                               .and line_starts_with('emergency_restart_threshold = ' + node['php']['fpm']['emergency_restart_threshold'])
                               .and line_starts_with('emergency_restart_interval = ' + node['php']['fpm']['emergency_restart_interval'])
                               .and line_starts_with('process_control_timeout = ' + node['php']['fpm']['process_control_timeout'])
                               .and line_starts_with('daemonize = ' + node['php']['fpm']['daemonize'])
                               .and line_starts_with('include=' + node['php']['fpm']['pool_dir'] + '/*.conf')
                           )
    end

    it 'creates php fpm pool config file with default values' do
      expect(converged).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(
                               line_matches('[test]')
                               .and line_matches('user = ' + node['php']['fpm']['default']['user'])
                               .and line_matches('group = ' + node['php']['fpm']['default']['group'])
                               .and line_matches('listen = ' + node['php']['fpm']['run_dir'] + '/test.php-fpm-sock')
                               .and line_matches('listen.user = ' + node['php']['fpm']['default']['socket_user'])
                               .and line_matches('listen.group = ' + node['php']['fpm']['default']['socket_group'])
                               .and line_matches('listen.mode = ' + node['php']['fpm']['default']['socket_mode'])
                               .and line_matches('pm = ' + node['php']['fpm']['default']['pm'])
                               .and line_matches('pm.max_children = ' + node['php']['fpm']['default']['max_children'])
                               .and line_matches('pm.start_servers = ' + node['php']['fpm']['default']['start_servers'])
                               .and line_matches('pm.min_spare_servers = ' + node['php']['fpm']['default']['min_spare_servers'])
                               .and line_matches('pm.max_spare_servers = ' + node['php']['fpm']['default']['max_spare_servers'])
                               .and line_matches('pm.max_requests = ' + node['php']['fpm']['default']['max_requests'])
                               .and line_matches('pm.status_path = ' + node['php']['fpm']['default']['status_path'])
                               .and line_matches('ping.path = ' + node['php']['fpm']['default']['ping_path'])
                               .and line_matches('ping.response = ' + node['php']['fpm']['default']['ping_response'])
                               .and line_matches('rlimit_files = ' + node['php']['fpm']['default']['rlimit_files'])
                               .and line_matches('rlimit_core = ' + node['php']['fpm']['default']['rlimit_core'])
                               .and line_matches('request_slowlog_timeout = ' + node['php']['fpm']['default']['request_slowlog_timeout'])
                               .and line_matches('slowlog = ' + File.join(node['php']['fpm']['log_dir'], node['php']['fpm']['default']['slowlog']))
                               .and line_matches('catch_workers_output = ' + node['php']['fpm']['default']['catch_workers_output'])
                           )
    end

    it 'creates env variable statements in pool config' do
      test_params.env['MAGE_IS_DEVELOPER_MODE'] = '1'
      expect(converged).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(
                               line_matches('env[MAGE_IS_DEVELOPER_MODE] = 1')
                           )
    end

    it 'creates php_flag variable statements in pool config' do
      test_params.php_flag.memory_limit = '512m'
      expect(converged).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(
                               line_matches('php_flag[memory_limit] = 512m')
                           )
    end

    it 'creates php_flag variable statements in pool config' do
      test_params.php_value.memory_limit = '512m'
      expect(converged).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(
                               line_matches('php_value[memory_limit] = 512m')
                           )
    end

    it 'creates php_admin_flag variable statements in pool config' do
      test_params.php_admin_flag.memory_limit = '512m'
      expect(converged).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(
                               line_matches('php_admin_flag[memory_limit] = 512m')
                           )
    end

    it 'creates php_admin_value variable statements in pool config' do
      test_params.php_admin_value.memory_limit = '512m'
      expect(converged).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(
                               line_matches('php_admin_value[memory_limit] = 512m')
                           )
    end

    it 'creates a pool for tpc ip listen' do
      test_params.socket = false
      test_params.port = '9999'
      expect(converged).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(line_matches('listen = 127.0.0.1:9999'))
    end

    it 'limits allowed ip addresses' do
      test_params.socket = false
      test_params.allowed_ip = %w(127.0.0.1 33.33.33.1)
      expect(converged).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(line_matches('listen.allowed_clients = 127.0.0.1,33.33.33.1'))
    end

    it 'allows to set backlog value' do
      test_params.queue_size = 100
      expect(converged).to render_file(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
                           .with_content(line_matches('listen.backlog = 100'))
    end

    it 'do not restart fpm service when fpm config is changed and no pools have been added before' do
      converged do
        stub_dir_glob(File.join(node['php']['fpm']['pool_dir'], '*.conf'), [])
      end
      template = chef_run.template(File.join(node['php']['fpm']['conf_dir'], 'php-fpm.conf'))
      expect(template).not_to notify('service[' + node['php']['fpm']['service'] + ']').to(:restart).delayed
      expect(template.updated_by_last_action?).to eq(true)
    end

    it 'restarts fpm service if pools have been added before' do
      converged do
        stub_dir_glob(File.join(node['php']['fpm']['pool_dir'], '*.conf'), ['test.conf'])
      end
      template = chef_run.template(File.join(node['php']['fpm']['conf_dir'], 'php-fpm.conf'))
      expect(template).to notify('service[' + node['php']['fpm']['service'] + ']').to(:restart).immediately
      expect(template.updated_by_last_action?).to eq(true)
    end

    it 'starts fpm service if pool config was updated and no pools have been started' do
      converged do
        stub_dir_glob(File.join(node['php']['fpm']['pool_dir'], '*.conf'), [])
      end

      template = chef_run.template(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
      expect(template).to notify('service[' + node['php']['fpm']['service'] + ']').to(:start).immediately
      expect(template.updated_by_last_action?).to eq(true)
    end

    it 'reloads fpm service if pool config was updated' do
      converged do
        stub_dir_glob(File.join(node['php']['fpm']['pool_dir'], '*.conf'), ['test.conf'])
      end
      template = chef_run.template(File.join(node['php']['fpm']['pool_dir'], 'test.conf'))
      expect(template).to notify('service[' + node['php']['fpm']['service'] + ']').to(:reload).immediately
      expect(template.updated_by_last_action?).to eq(true)
    end
  end
end