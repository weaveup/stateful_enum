# frozen_string_literal: true

class User < ActiveRecord::Base
  enum account_status: {active: 0, withdrawn: 1} do
    event :withdraw do
      transition :active => :withdrawn
    end
  end

  enum player_status: {normal: 0, poison: 1, dead: 2} do
    event :die do
      transition [:normal, :poison] => :dead
    end
  end
end
