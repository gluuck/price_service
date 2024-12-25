# frozen_string_literal: true

class CalculatedPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :calculated_prices do |t|
      t.references :contract, null: false, foreign_key: true
      t.references :offer, null: false, foreign_key: true
      t.float :price
      t.datetime :calculated_at

      t.timestamps
    end
  end
end
