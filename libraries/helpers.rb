module EcomDev
  module PhpFpm
    module Helpers
      include Chef::Mixin::DeepMerge
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
      def php_fpm_listen_for_fastcgi(pool_name)
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
          params[:user] =  options[:socket_user]
          params[:group] =  options[:socket_group]
          params[:mode] =  options[:socket_mode]
        else
          params[:allowed_clients] = Array(options[:allowed_ip]).join(',')
        end

        if options.queue_size
          params[:backlog] = options.queue_size
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