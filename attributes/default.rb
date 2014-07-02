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
# List of latest available PHP versions with their checksums for download
default['php_versions']['5.3']['version'] = '5.3.28'
default['php_versions']['5.3']['checksum'] = 'eec3fb5ccb6d8c238f973d306bebb00e'
default['php_versions']['5.4']['version'] = '5.4.29'
default['php_versions']['5.4']['checksum'] = '9caf973b19ba93bb2b78f78c61643d5d'
default['php_versions']['5.5']['version'] = '5.5.13'
default['php_versions']['5.5']['checksum'] = '32d0fc26fccdb249a918c0e01ffb7b82'

default['php']['major_version'] = '5.5'

include_attribute 'php'

if platform_family?('debian')
  node.set['apt']['compiletime'] = true
  node.set['apt']['compile_time_update'] = true
elsif platform_family?('rhel')
  old_prefix_dir = node['php']['prefix_dir']
  old_configure_opts = default['php']['configure_options']

  default['php']['prefix_dir'] = '/usr'

  default['php']['configure_options'] = old_configure_opts.collect do |v|
    v.sub(/^\-\-prefix\=#{Regexp.escape(old_prefix_dir)}$/, '--prefix=' + node['php']['prefix_dir'])
  end
end

default['php']['recompile'] = false

