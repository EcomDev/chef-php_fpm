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
class Chef
  class Resource
    class LWRPBase

      def init_default_attribute_value(variable, default_data, default_symbol)
        value = send(variable.to_sym)
        if value == default_symbol && default_data.key?(variable)
          default_value = default_data[variable]
          if default_value.is_a?(Array)
            value = default_value.to_a
          elsif default_value.is_a?(Hash)
            value = default_value.to_hash
          else
            value = default_value
          end
          send(variable.to_sym, value) # It doesn't set default nil values
        end
      end

      def dump_attribute_values(default_data, default_symbol)
        values = Hash.new
        self.attribute_names.each do |key|
          init_default_attribute_value(key, default_data, default_symbol)
          value = send(key.to_sym)
          if value == default_symbol
            value = nil
          end
          values[key] = value
        end
        values
      end

      def attribute_names
         return @attribute_names if @attribute_names
         @attribute_names = Array.new
         methods.select {|name| name.to_s.match(/^_set_or_return_/)}
         .each { |method| @attribute_names << method.to_s.sub(/^_set_or_return_/, '').to_sym }
         @attribute_names
      end

      def update_from_resources(resources = [])
         updated_by_last_action(resources.any? { |r| r.updated_by_last_action? })
         self
      end
    end
  end
end