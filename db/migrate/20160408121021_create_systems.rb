class CreateSystems < ActiveRecord::Migration
  def change
    create_table :systems do |t|
      t.string :version
      t.integer :years, array: true, default: []
      t.string :text_de
      t.string :text_fr
      t.string :text_it
    end
  end
end
