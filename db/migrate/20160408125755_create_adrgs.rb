class CreateAdrgs < ActiveRecord::Migration
  def change
    create_table :adrgs do |t|
      t.string :code
      t.string :version
      t.string :text_de
      t.string :text_fr
      t.string :text_it
      t.integer :partition_id
      t.integer :mdc_id
    end
  end
end
