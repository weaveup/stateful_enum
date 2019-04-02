# frozen_string_literal: true

require 'stateful_enum/machine'

module StatefulEnum
  module StateInspection
    # List of possible events from the current state
    def possible_events
      events = self.class.instance_variable_get(:@_stateful_enum).events
      events.select {|e| send("can_#{e.value_method_name}?") }
    end
  end
end
