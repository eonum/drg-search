class AddPartitionLetterToDrgs < ActiveRecord::Migration
  def change
    add_column :drgs, :partition_letter, :string
  end
end
