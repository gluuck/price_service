# frozen_string_literal: true

class PriseRules < ActiveRecord::Migration[7.0]
  def change
    create_table :price_rules do |t|
      t.references :contract, null: false, foreign_key: true
      t.references :product_group, null: false, foreign_key: true
      t.integer :priority, null: false
      t.integer :discount_percentage
      t.datetime :updated_at
    end
  end
end
