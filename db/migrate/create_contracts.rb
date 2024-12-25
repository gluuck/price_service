# frozen_string_literal: true

class Contracts < ActiveRecord::Migration[7.0]
  def change
    create_table :contracts do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :number
      t.date :valid_from
      t.date :valid_until
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
