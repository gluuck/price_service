# frozen_string_literal: true

class Offers < ActiveRecord::Migration[7.0]
  def change
    create_table :offers do |t|
      t.references :product, null: false, foreign_key: true
      t.float :base_price
      t.integer :stock_quantity
      t.integer :delivery_time_days
      t.integer :bonus_points

      t.timestamps
    end
  end
end
