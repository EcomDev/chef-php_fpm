# List of latest available PHP versions with their checksums for download
default['php_versions']['5.3']['version'] = '5.3.28'
default['php_versions']['5.3']['checksum'] = 'eec3fb5ccb6d8c238f973d306bebb00e'
default['php_versions']['5.4']['version'] = '5.4.29'
default['php_versions']['5.4']['checksum'] = '9caf973b19ba93bb2b78f78c61643d5d'
default['php_versions']['5.5']['version'] = '5.5.13'
default['php_versions']['5.5']['checksum'] = '32d0fc26fccdb249a918c0e01ffb7b82'

include_attribute 'php'

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

default['php']['recompile'] = false

