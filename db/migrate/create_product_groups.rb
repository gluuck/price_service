# frozen_string_literal: true

class ProductGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :product_groups do |t|
      t.string :name
      t.timestamps
    end
  end
end
