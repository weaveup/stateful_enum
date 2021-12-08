# frozen_string_literal: true

require 'stateful_enum/machine'

module StatefulEnum
  module ActiveRecordEnumExtension
    #   enum status: {unassigned: 0, assigned: 1, resolved: 2, closed: 3} do
    #     event :assign do
    #       transition :unassigned => :assigned
    #     end
    #   end
    if Rails::VERSION::MAJOR >= 7
      def enum(name = nil, values = nil, **options, &block)
        return super unless block

        definitions = super name, values, **options

        if name
          (@_defined_stateful_enums ||= []) << StatefulEnum::Machine.new(self, name, (definitions.is_a?(Hash) ? definitions.keys : definitions), options[:prefix], options[:suffix], &block)
        else
          definitions.each do |column, states|
            (@_defined_stateful_enums ||= []) << StatefulEnum::Machine.new(self, column, (states.is_a?(Hash) ? states.keys : states), options[:_prefix], options[:_suffix], &block)
          end
        end

        definitions
      end
    else
      def enum(definitions, &block)
        return super unless block

        # Preserving prefix and suffix values before calling super because the super destroys the given Hash
        prefix, suffix = definitions[:_prefix], definitions[:_suffix] if Rails::VERSION::MAJOR >= 5
        enum_values = super definitions

        enum_values.each_pair do |column, states|
          (@_defined_stateful_enums ||= []) << StatefulEnum::Machine.new(self, column, (states.is_a?(Hash) ? states.keys : states), prefix, suffix, &block)
        end
      end
    end
  end
end
