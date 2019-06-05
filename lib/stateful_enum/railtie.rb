# frozen_string_literal: true

require 'stateful_enum/active_record_extension'
require 'stateful_enum/state_inspection'

module StatefulEnum
  class Railtie < ::Rails::Railtie
    initializer 'stateful_enum' do
      ActiveSupport.on_load :active_record do
        ::ActiveRecord::Base.extend StatefulEnum::ActiveRecordEnumExtension
        ::ActiveRecord::Base.include StatefulEnum::StateInspection
      end
    end
  end
end
