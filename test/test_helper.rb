# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
ActiveRecord::Migration.verbose = false
if ActiveRecord::Migrator.respond_to? :migrate
  ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)])
else
  ActiveRecord::Migrator.migrations_paths << File.expand_path('../dummy/db/migrate', __FILE__)
  ActiveRecord::Tasks::DatabaseTasks.drop_current 'test'
  ActiveRecord::Tasks::DatabaseTasks.create_current 'test'
  ActiveRecord::Tasks::DatabaseTasks.migrate
end

require 'test/unit/rails/test_help'


# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.fixtures :all
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'stateful_enum'
