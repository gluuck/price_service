class Products < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku
      t.string :brand
      t.text :description
      t.string :image_url
      t.timestamps
    end
  end
end
