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
  namespace '5.4' do
    version '5.4.37'
    checksum '42494eea588dea228719757deca03d30'
  end

  namespace '5.5' do
    version '5.5.21'
    checksum '63f8d358d651adef906f650175c796b1'
  end

  namespace '5.6' do
    version '5.6.5'
    checksum '636b73f378000de933081319cad586d6'
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
