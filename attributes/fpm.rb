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
namespace 'php', 'fpm' do
  pool_dir_name 'pool.d'
  if platform_family?('rhel', 'fedora')
    conf_dir '/etc'
    pool_dir_name 'php-fpm.d'
    log_dir '/var/log/php-fpm'
    logrotate_file '/etc/logrotate.d/php-fpm'
    run_dir '/var/run/php-fpm'
    service 'php-fpm'
  else
    conf_dir '/etc/php5/fpm'
    log_dir '/var/log/php5-fpm'
    logrotate_file '/etc/logrotate.d/php5-fpm'
    run_dir '/var/run'
    service  'php5-fpm'
  end

  disable_default_pool true
end

# Default FPM pool settings
namespace 'php', 'fpm', 'default' do
  user 'www-data'
  user 'nobody' if platform_family?('rhel')
  group node['php']['fpm']['default']['user']

  socket true
  socket_user node['php']['fpm']['default']['user']
  socket_group node['php']['fpm']['default']['socket_user']
  socket_mode '0644'

  ip '127.0.0.1'
  port '9000'

  prefix  nil

  pm 'dynamic'
  max_children '6'
  start_servers '4'
  min_spare_servers '3'
  max_spare_servers '5'
  max_requests '500'
  queue_size nil

  status_path '/status'
  ping_path '/ping'
  ping_response 'pong'

  request_terminate_timeout nil
  request_slowlog_timeout '5s'
  slowlog '$pool.log.slow'

  rlimit_files '4096'
  rlimit_core '0'

  chroot nil
  chdir nil

  catch_workers_output 'no'
  limit_extensions Array.new
  allowed_ip ['127.0.0.1']

  env  Hash.new
  php_value  Hash.new
  php_flag Hash.new
  php_admin_value Hash.new
  php_admin_flag Hash.new
end


namespace 'php', 'fpm' do
  pool_dir File.join(node.php.fpm.conf_dir, node.php.fpm.pool_dir_name)
  pid File.join(node['php']['fpm']['run_dir'], node['php']['fpm']['service'] + '.pid')
  error_log File.join(node['php']['fpm']['log_dir'], 'fpm-master.log')
  log_level 'notice'
  emergency_restart_threshold '16'
  emergency_restart_interval '1h'
  process_control_timeout '30s'
  daemonize  'yes'
  global_setting_names  %w(
    pid error_log log_level emergency_restart_threshold
    emergency_restart_interval process_control_timeout
    daemonize
  )
end
