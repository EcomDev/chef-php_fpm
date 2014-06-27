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
default['php']['fpm']['pool_dir_name'] = 'pool.d'

case node['platform_family']
  when 'rhel', 'fedora'
    default['php']['fpm']['conf_dir']  = '/etc'
    default['php']['fpm']['pool_dir_name'] = 'php-fpm.d'
    default['php']['fpm']['log_dir']   = '/var/log/php-fpm'
    default['php']['fpm']['logrotate_file']   = '/etc/logrotate.d/php-fpm'
    default['php']['fpm']['run_dir']   = '/var/run/php-fpm'
    default['php']['fpm']['service']   = 'php-fpm'
  when 'debian'
    default['php']['fpm']['conf_dir']  = '/etc/php5/fpm'
    default['php']['fpm']['log_dir']   = '/var/log/php5-fpm'
    default['php']['fpm']['logrotate_file']   = '/etc/logrotate.d/php5-fpm'
    default['php']['fpm']['run_dir']   = '/var/run'
    default['php']['fpm']['service']   = 'php5-fpm'
  else
    default['php']['fpm']['conf_dir']  = '/etc/php5/fpm'
    default['php']['fpm']['log_dir']   = '/var/log/php5-fpm'
    default['php']['fpm']['logrotate_file']   = '/etc/logrotate.d/php5-fpm'
    default['php']['fpm']['run_dir']   = '/var/run'
    default['php']['fpm']['service']   = 'php5-fpm'
end

default['php']['fpm']['pool_dir']  = File.join(node['php']['fpm']['conf_dir'], default['php']['fpm']['pool_dir_name'])

default['php']['fpm']['disable_default_pool'] = true

# Default FPM pool settings
default['php']['fpm']['default']['user'] = 'www-data'
default['php']['fpm']['default']['user'] = 'nobody' if platform_family?('rhel')
default['php']['fpm']['default']['group'] = node['php']['fpm']['default']['user']

default['php']['fpm']['default']['socket'] = true
default['php']['fpm']['default']['socket_user'] = node['php']['fpm']['default']['user']
default['php']['fpm']['default']['socket_group'] = node['php']['fpm']['default']['socket_user']
default['php']['fpm']['default']['socket_mode'] = '0644'

default['php']['fpm']['default']['ip'] = '127.0.0.1'
default['php']['fpm']['default']['port'] = '9000'

default['php']['fpm']['default']['prefix'] = nil

default['php']['fpm']['default']['pm'] = 'dynamic'
default['php']['fpm']['default']['max_children'] = '6'
default['php']['fpm']['default']['start_servers'] = '4'
default['php']['fpm']['default']['min_spare_servers'] = '3'
default['php']['fpm']['default']['max_spare_servers'] = '5'
default['php']['fpm']['default']['max_requests'] = '500'
default['php']['fpm']['default']['queue_size'] = nil

default['php']['fpm']['default']['status_path'] = '/status'
default['php']['fpm']['default']['ping_path'] = '/ping'
default['php']['fpm']['default']['ping_response'] = 'pong'

default['php']['fpm']['default']['request_terminate_timeout'] = nil
default['php']['fpm']['default']['request_slowlog_timeout'] = '5s'
default['php']['fpm']['default']['slowlog'] = '$pool.log.slow'

default['php']['fpm']['default']['rlimit_files'] = '4096'
default['php']['fpm']['default']['rlimit_core'] = '0'

default['php']['fpm']['default']['chroot'] = nil
default['php']['fpm']['default']['chdir'] = nil

default['php']['fpm']['default']['catch_workers_output'] = 'no'
default['php']['fpm']['default']['limit_extensions'] = []
default['php']['fpm']['default']['allowed_ip'] = ['127.0.0.1']

default['php']['fpm']['default']['env'] = Hash.new
default['php']['fpm']['default']['php_value'] = Hash.new
default['php']['fpm']['default']['php_flag'] = Hash.new
default['php']['fpm']['default']['php_admin_value'] = Hash.new
default['php']['fpm']['default']['php_admin_flag'] = Hash.new


# Global php-fpm settings
default['php']['fpm']['pid']   =  File.join(node['php']['fpm']['run_dir'], node['php']['fpm']['service'] + '.pid')
default['php']['fpm']['error_log']   = File.join(node['php']['fpm']['log_dir'], 'fpm-master.log')
default['php']['fpm']['log_level'] = 'notice'
default['php']['fpm']['emergency_restart_threshold'] = '16'
default['php']['fpm']['emergency_restart_interval'] = '1h'
default['php']['fpm']['process_control_timeout'] = '30s'
default['php']['fpm']['daemonize'] = 'yes'

default['php']['fpm']['global_setting_names'] = %w(
  pid error_log log_level emergency_restart_threshold
  emergency_restart_interval process_control_timeout
  daemonize
)