# frozen_string_literal: true

require 'stateful_enum/machine'

module StatefulEnum
  module StateInspection
    extend ActiveSupport::Concern

    module ClassMethods
      def stateful_enum
        @_defined_stateful_enums
      end
    end

    def stateful_enum
      StateInspector.new(self.class.stateful_enum, self)
    end
  end

  class StateInspector
    def initialize(defined_stateful_enums, model_instance)
      @defined_stateful_enums, @model_instance = defined_stateful_enums, model_instance
    end

    # List of possible events from the current state
    def possible_events
      @defined_stateful_enums.flat_map {|se| se.events.select {|e| @model_instance.send("can_#{e.value_method_name}?") } }
    end

    # List of possible event names from the current state
    def possible_event_names
      possible_events.map(&:value_method_name)
    end

    # List of transitionable states from the current state
    def possible_states
      @defined_stateful_enums.flat_map do |stateful_enum|
        col = stateful_enum.instance_variable_get :@column
        pe = stateful_enum.events.select {|e| @model_instance.send("can_#{e.value_method_name}?") }
        pe.flat_map {|e| e.transitions[@model_instance.send(col).to_sym].first }
      end
    end
  end
end
