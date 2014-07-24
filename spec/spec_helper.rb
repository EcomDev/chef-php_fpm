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
require 'chefspec'
require 'chefspec/berkshelf'
require 'ecomdev/chefspec'

module SpecHelper
  def stub_dir_existence(config, exist=true)
    stub_file_exists(config[:conf_dir], exist)
    stub_file_exists(config[:pool_dir], exist)
    stub_file_exists(config[:log_dir], exist)
    stub_file_exists(config[:run_dir], exist)
  end

  def stub_php_vars(node, version_alias='5.test', version='5.1.0', checksum='test1', bin='test-php-bin')
    node.set['php_versions'][version_alias]['version'] = version
    node.set['php_versions'][version_alias]['checksum'] = checksum
    node.set['php']['major_version'] = version_alias
    node.set['php']['bin'] = bin
  end

end

EcomDev::ChefSpec::Helpers::Platform.platform_path = File.dirname(__FILE__)
EcomDev::ChefSpec::Helpers::Platform.platform_file = 'platforms.json'
EcomDev::ChefSpec::Configuration.cookbook_path('spec/fixtures')

ChefSpec::Coverage.start!