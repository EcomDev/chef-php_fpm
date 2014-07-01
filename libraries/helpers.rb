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
module EcomDev
  module PhpFpm
    module Helpers
      # @return Mash
      def php_fpm_pool_options(pool_name, options=nil)
        if options.nil?
          rise 'Pool with name ' + pool_name + ' is not found' unless node['php']['_fpm_listen'].attribute?(pool_name)
          node['php']['_fpm_listen'][pool_name]
        else
          node.set['php']['_fpm_listen'][pool_name] = options
          options
        end
      end

      # returns a string formatted for fastcgi listen
      def fpm_fastcgi_listen(pool_name)
        options = php_fpm_pool_options(pool_name)
        listen = generate_php_fpm_listen(pool_name)

        if options['socket']
          'unix:/' + listen
        else
          listen
        end
      end

      # stores options of php-fpm pool
      def php_fpm_listen(pool_name, options)
        php_fpm_pool_options(pool_name, options)
        generate_php_fpm_listen(pool_name)
      end

      def generate_php_fpm_listen(pool_name)
        options = php_fpm_pool_options(pool_name)
        if options.key?('socket') && options['socket']
          File.join(node['php']['fpm']['run_dir'], pool_name + '.php-fpm-sock')
        else
          String(options['ip']) + ':' + String(options['port'])
        end
      end

      def generate_php_fpm_listen_params(pool_name)
        options = php_fpm_pool_options(pool_name)
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
    end
  end
end

class Chef
  class Recipe
    include EcomDev::PhpFpm::Helpers
  end
end

class Chef
  class Resource
    include EcomDev::PhpFpm::Helpers
  end
end