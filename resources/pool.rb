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
actions :create, :delete

attribute :name, :kind_of => [String, Symbol], :name_attribute => true # Name of the fpm app
attribute :user, :kind_of => [String, Symbol], :default => :fpm_default # User for php process, by default will take value from node[fpm]
attribute :group, :kind_of => [String, Symbol], :default => :fpm_default # Group for php process

attribute :socket, :kind_of => [TrueClass, FalseClass, Symbol], :default => :fpm_default # Use socket
attribute :socket_user, :kind_of => [String, Symbol], :default => :fpm_default # Use socket
attribute :socket_group, :kind_of => [String, Symbol], :default => :fpm_default # Use socket
attribute :socket_mode, :kind_of => [String, Symbol], :default => :fpm_default # Use socket

attribute :ip, :kind_of => [String, Symbol], :default => '127.0.0.1' # Listen value for FPM process
attribute :port, :kind_of => [String, Symbol], :default => '9000' # Listen value for FPM process
attribute :prefix, :kind_of => [String, NilClass, Symbol], :default => nil # Prefix for php process files

# Process manager options
attribute :pm, :kind_of => [String, Symbol], :equal_to => %w(dynamic static), :default => :fpm_default # Type of process manager
attribute :max_children, :kind_of => [Fixnum, String, Symbol], default: :fpm_default
attribute :start_servers, :kind_of => [Fixnum, String, Symbol], default: :fpm_default
attribute :min_spare_servers, :kind_of => [Fixnum, String, Symbol], default: :fpm_default
attribute :max_spare_servers, :kind_of => [Fixnum, String, Symbol], default: :fpm_default
attribute :max_requests, :kind_of => [Fixnum, String, Symbol], default: :fpm_default
attribute :queue_size, :kind_of => [Fixnum, String, Symbol], default: :fpm_default

# Status hook options
attribute :status_path, :kind_of => [String, NilClass, Symbol], default: :fpm_default
attribute :ping_path, :kind_of => [String, NilClass, Symbol], default: :fpm_default
attribute :ping_response, :kind_of => [String, Symbol], default: :fpm_default

# Slow requests log
attribute :request_terminate_timeout, :kind_of => [String, NilClass, Symbol], default: :fpm_default
attribute :request_slowlog_timeout, :kind_of => [String, NilClass, Symbol], default: :fpm_default
attribute :slowlog, :kind_of => [String, NilClass, Symbol], default: :fpm_default

# Tune options for process count
attribute :rlimit_files, :kind_of => [Fixnum, String, NilClass, Symbol], default: :fpm_default
attribute :rlimit_core, :kind_of => [Fixnum, String, NilClass, Symbol], default: :fpm_default

# Security options
attribute :chroot, :kind_of => [String, NilClass, Symbol], default: :fpm_default
attribute :chdir, :kind_of => [String, NilClass, Symbol], default: :fpm_default

# Workers output
attribute :catch_workers_output, :kind_of => [String, Symbol], :equal_to => %w(yes no), default: :fpm_default

# Security
attribute :limit_extensions, :kind_of => [Array, Symbol], default: :fpm_default
attribute :allowed_ip, :kind_of => [Array, Symbol], default: :fpm_default

# Ini or environment options
attribute :env, :kind_of => [Hash, Symbol], default: :fpm_default
attribute :php_value, :kind_of => [Hash, Symbol], default: :fpm_default
attribute :php_flag, :kind_of => [Hash, Symbol], default: :fpm_default
attribute :php_admin_value, :kind_of => [Hash, Symbol], default: :fpm_default
attribute :php_admin_flag, :kind_of => [Hash, Symbol], default: :fpm_default

def initialize(*args)
  super
  @action = :create
end

public

def any_pools?
  !pools.empty?
end

def pools
  ::Dir.glob(::File.join(node['php']['fpm']['pool_dir'], '*.conf'))
end

def only_this_pool?
  pools == [::File.join(node['php']['fpm']['pool_dir'], name + '.conf')]
end

def after_create
  pool_options # initializes pool options
  super
end

def pool_options
  unless node.shared_data?(:resource, :php_fpm_pool, name)
    node.shared_data(:resource, :php_fpm_pool, name,
                     dump_attribute_values(node['php']['fpm']['default'], :fpm_default))

  end

  node.shared_data(:resource, :php_fpm_pool, name)
end