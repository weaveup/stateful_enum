# frozen_string_literal: true

class CreateUsers < (Rails::VERSION::STRING >= '5' ? ActiveRecord::Migration[5.0] : ActiveRecord::Migration)
  def change
    create_table :users do |t|
      t.string :name
      t.integer :account_status
      t.integer :player_status

      t.timestamps null: false
    end
  end
end
