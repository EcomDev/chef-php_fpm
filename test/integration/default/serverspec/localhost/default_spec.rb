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
require 'spec_helper'

expected_php_version = '5.5.13'
service_name = 'php5-fpm'
service_name = 'php-fpm' if os[:family] == 'RedHat'

describe service(service_name) do
   it { should be_enabled }
   it { should be_running }
end

describe process('php-fpm') do
  it { should be_running }
end

describe command('php -v') do
  it { should return_stdout /PHP\s#{Regexp.escape(expected_php_version)}\s/ }
end