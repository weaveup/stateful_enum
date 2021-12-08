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
        definitions = super
        return definitions unless block

        definitions.each do |name, values|
          (@_defined_stateful_enums ||= []) << StatefulEnum::Machine.new(self, name, (values.is_a?(Hash) ? values.keys : values), options[:prefix], options[:suffix], &block)
        end
      end
    else
      def enum(definitions, &block)
        prefix, suffix = definitions[:_prefix], definitions[:_suffix] if Rails::VERSION::MAJOR >= 5
        enum = super definitions
        return enum unless block

        enum.each_pair do |column, states|
          (@_defined_stateful_enums ||= []) << StatefulEnum::Machine.new(self, column, (states.is_a?(Hash) ? states.keys : states), prefix, suffix, &block)
        end
      end
    end
  end
end
