class CreatePartitions < ActiveRecord::Migration
  def change
    create_table :partitions do |t|
      t.string :code
      t.string :version
      t.integer :mdc_id
    end
  end
end
