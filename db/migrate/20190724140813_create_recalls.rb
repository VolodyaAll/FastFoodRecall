class CreateRecalls < ActiveRecord::Migration[5.2]
  def change
    create_table :recalls do |t|
      t.belongs_to :shop, index: true
      t.text :author
      t.text :comment
      t.integer :rating

      t.timestamps 
    end
  end
end
