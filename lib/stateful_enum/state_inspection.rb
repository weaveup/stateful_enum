# frozen_string_literal: true

require 'stateful_enum/machine'

module StatefulEnum
  module StateInspection
    # List of possible events from the current state
    def possible_events
      events = self.class.instance_variable_get(:@_stateful_enum).instance_variable_get(:@events)
      events.select {|e| send("can_#{e.instance_variable_get(:@value_method_name)}?") }
    end
  end
end
