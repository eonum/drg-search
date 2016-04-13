class CreateDrgs < ActiveRecord::Migration
  def change
    create_table :drgs do |t|
      t.string :code
      t.string :version
      t.string :text_de
      t.string :text_fr
      t.string :text_it
      t.integer :mdc_id
      t.integer :partition_id
      t.integer :adrg_id
    end
  end
end
