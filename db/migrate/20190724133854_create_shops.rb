class CreateShops < ActiveRecord::Migration[5.2]
  def change
    create_table :shops do |t|
      t.text :name
      t.text :description
      t.text :adress
      t.float :rating

      t.timestamps 
    end
  end
end
