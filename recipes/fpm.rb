include_recipe 'php_fpm::default'

directories = {
    node['php']['fpm']['conf_dir'] => 00755,
    node['php']['fpm']['pool_dir'] => 00755,
    node['php']['fpm']['log_dir'] => 01733,
    node['php']['fpm']['run_dir'] => 00755,
}

directories.each do |dir_name, dir_mode|
  directory dir_name do
    action :create
    user 'root'
    group 'root'
    mode dir_mode
    recursive true
    not_if { File.exist?(dir_name) }
  end
end

# PHP-FPM Service definition
template '/etc/init.d/' + node['php']['fpm']['service'] do
  source 'init.d.erb'
  owner 'root'
  group 'root'
  mode 00755
end

file node['php']['fpm']['pool_dir'] + '/www.conf' do
  action :delete
  only_if { node['php']['fpm']['disable_default_pool'] }
end

service node['php']['fpm']['service'] do
  supports :start => true, :stop => true, :reload => true, :status => true, :restart => true
  action :enable
end

# PHP-FPM Service definition
template node['php']['fpm']['logrotate_file'] do
  source 'logrotate.erb'
  owner 'root'
  group 'root'
  mode 00755
end