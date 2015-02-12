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

php_version = node.deep_fetch!('php', 'major_version')


raise 'PHP version '+ php_version + ' is unknown' unless node.deep_fetch('php_versions', php_version)

php_prefix = node.deep_fetch!('php', 'prefix_dir')
php_prefix = '/usr' if rhel?
full_version = node.deep_fetch!('php_versions', php_version, 'version')

node.namespace 'php', precedence: node.set  do
  install_method 'source'
  version full_version
  checksum node.deep_fetch!('php_versions', php_version, 'checksum')
  prefix_dir php_prefix unless node['php']['prefix'] == php_prefix
  ext_dir ::File.join(php_prefix, 'lib', 'php', 'modules', full_version)
  unless node.deep_fetch!('php', 'ext_conf_dir').match(/[\/\\]#{Regexp.escape(full_version)}$/)
    ext_conf_dir ::File.join(node.deep_fetch!('php', 'ext_conf_dir'), full_version)
  end
end

node.from_file(run_context.resolve_attribute('php', 'default'))

configure_options = node.deep_fetch!('php', 'configure_options')
configure_options << '--with-jpeg-dir'
configure_options << '--with-png-dir'

node.set[:php][:configure_options] = configure_options

if node['php']['recompile']
  php_binary = php_prefix + '/bin/' + node['php']['bin']
  php_version_match = 'test -f ' + php_binary + ' && ('+ php_binary +' -v | grep "PHP ' + node['php']['version'] +'")'
  file php_binary do
    action :delete
    not_if php_version_match
  end
end

if debian?
  include_recipe 'apt::default'
end

include_recipe 'php::default'



