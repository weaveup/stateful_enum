# frozen_string_literal: true

require 'test_helper'

class StateInspectionTest < ActiveSupport::TestCase
  def test_possible_events
    unassigned_bug = Bug.new status: :assigned, assigned_to: User.create!(name: 'matz')
    assert_equal %w[resolve close], unassigned_bug.stateful_enum.possible_events.map(&:value_method_name)
  end

  def test_possible_event_names
    unassigned_bug = Bug.new status: :assigned, assigned_to: User.create!(name: 'matz')
    assert_equal %w[resolve close], unassigned_bug.stateful_enum.possible_event_names
  end
end
