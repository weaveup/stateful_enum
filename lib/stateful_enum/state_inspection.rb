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

    # List of possible events from the current state
    def possible_events
      events = self.class.stateful_enum.events
      events.select {|e| send("can_#{e.value_method_name}?") }
    end
  end
end
