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
    not_if { ::File.exists?(dir_name) }
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