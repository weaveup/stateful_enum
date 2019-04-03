# frozen_string_literal: true

require 'stateful_enum/machine'

module StatefulEnum
  module StateInspection
    extend ActiveSupport::Concern

    class_methods do
      def stateful_enum
        @_stateful_enum
      end
    end

    def stateful_enum
      StateInspector.new(self.class.stateful_enum, self)
    end
  end

  class StateInspector
    def initialize(stateful_enum, model_instance)
      @stateful_enum, @model_instance = stateful_enum, model_instance
    end

    # List of possible events from the current state
    def possible_events
      @stateful_enum.events.select {|e| @model_instance.send("can_#{e.value_method_name}?") }
    end

    # List of possible event names from the current state
    def possible_event_names
      possible_events.map(&:value_method_name)
    end
  end
end
