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
# Support whyrun
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  run_context.include_recipe 'php_fpm::fpm'
  resource = Array.new
  variables = new_resource.pool_options.clone
  variables[:listen] =  fpm_listen
  variables[:listen_params] = fpm_listen_params

  resource <<= template "#{node['php']['fpm']['conf_dir']}/php-fpm.conf" do
    owner 'root'
    group 'root'
    source 'conf.erb'
    cookbook 'php_fpm'
    if new_resource.any_pools?
      notifies :restart, 'service[' + node['php']['fpm']['service'] + ']', :immediately
    end
    mode 00644
  end

  resource <<= template "#{node['php']['fpm']['pool_dir']}/#{new_resource.name}.conf" do
    owner 'root'
    group 'root'
    mode '755'
    source 'pool.erb'
    cookbook 'php_fpm'
    variables(
        params: variables
    )
    if new_resource.any_pools?
      notifies :reload, 'service[' + node['php']['fpm']['service'] + ']', :immediately
    else
      notifies :start, 'service[' + node['php']['fpm']['service'] + ']', :immediately
    end
  end

  new_resource.update_from_resources(resource)
end

action :delete do
  run_context.include_recipe 'php_fpm::fpm'
  resource = Array.new
  resource <<= file "#{node['php']['fpm']['pool_dir']}/#{new_resource.name}.conf" do
    action :delete
    if new_resource.only_this_pool?
      notifies :stop, 'service[' + node['php']['fpm']['service'] + ']', :immediately
    else
      notifies :reload, 'service[' + node['php']['fpm']['service'] + ']', :immediately
    end
  end

  new_resource.update_from_resources(resource)
end

def current_resource(resource = nil)
  resource || new_resource
end

def fpm_listen(resource = nil)
  resource = current_resource(resource)
  options = resource.pool_options
  if options.key?('socket') && options['socket']
    resource.socket_path
  else
    String(options['ip']) + ':' + String(options['port'])
  end
end

def fpm_listen_params(resource = nil)
  resource = current_resource(resource)
  options = resource.pool_options
  params = Hash.new
  if options.key?('socket') && options['socket']
    params[:owner] =  options[:socket_user]
    params[:group] =  options[:socket_group]
    params[:mode] =  options[:socket_mode]
  else
    params[:allowed_clients] = Array(options[:allowed_ip]).join(',')
  end

  if options[:queue_size]
    params[:backlog] = options[:queue_size]
  end

  params
end