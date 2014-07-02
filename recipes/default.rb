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

php_version = node['php']['major_version']

raise 'PHP version '+ php_version + ' is unknown' unless node['php_versions'].attribute?(php_version)

node.set['php']['install_method'] = 'source'
node.set['php']['version'] = node['php_versions'][php_version]['version']
node.set['php']['checksum'] = node['php_versions'][php_version]['checksum']

if node['php']['recompile']
  php_binary = node['php']['prefix_dir'] + '/bin/' + node['php']['bin']
  php_version_match = 'test -f ' + php_binary + ' && ('+ php_binary +' -v | grep "PHP ' + node['php']['version'] +'")'
  file php_binary do
    action :delete
    not_if php_version_match
  end
end

if node.platform_family?('debian')
  include_recipe 'apt::default'
end

include_recipe 'php::default'



