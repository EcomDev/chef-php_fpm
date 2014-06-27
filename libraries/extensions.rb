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

      def hash_fill_default_options(variables, attribute, expected_symbol)
        attribute.each_pair do |key, value|
          if variables.key?(key.to_sym) && variables[key.to_sym] == expected_symbol
            variables[key.to_sym] = value
          end
        end

        variables
      end

      def dump_attribute_values
        values = Hash.new
        self.attribute_names.each { |key| values[key] = send(key.to_sym) }
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