class CreateThings < ActiveRecord::Migration
  def change
    create_table :things do |t|
      t.string :name
      t.string :path
      t.text :description

      t.timestamps
    end
  end
end
