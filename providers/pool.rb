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

action :create do
  run_context.include_recipe 'php_fpm::fpm'
  resource = Array.new
  variables = new_resource.dump_attribute_values(
      node['php']['fpm']['default'],
      :fpm_default
  )

  variables[:listen] = new_resource.php_fpm_listen(new_resource.name, variables)
  variables[:listen_params] = new_resource.generate_php_fpm_listen_params(new_resource.name)

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