# frozen_string_literal: true

class PriceGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :price_groups do |t|
      t.string :name
      t.timestamps
    end
  end
end
