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
      end

      class << self
        @attribute_names = Array.new
        attr_accessor :attribute_names
        alias_method :original_attribute, :attribute

        def attribute(name, validation_opts={})
          attribute_names(name)
          original_attribute(name, validation_opts)
        end

        def attribute_names(attribute_name=nil)
          @attribute_names ||= Array.new
          @attribute_names << attribute_name unless attribute_name.nil?
          @attribute_names
        end
      end
    end
  end
end