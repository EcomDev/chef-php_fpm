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

namespace 'php_versions' do
  namespace '5.3' do
    version '5.3.28'
    checksum 'eec3fb5ccb6d8c238f973d306bebb00e'
  end

  namespace '5.4' do
    version '5.4.30'
    checksum '461afd4b84778c5845b71e837776139f'
  end

  namespace '5.5' do
    version '5.5.14'
    checksum 'b34262d4ccbb6bef8d2cf83840625201'
  end
end

namespace 'php' do
  major_version '5.5'
  recompile false
end

if platform_family?('debian')
  namespace 'apt', precedence: normal do
    compiletime true
    compile_time_update true
  end
end

include_attribute 'php'
