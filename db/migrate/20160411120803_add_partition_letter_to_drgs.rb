class AddPartitionLetterToDrgs < ActiveRecord::Migration[5.2]
  def change
    add_column :drgs, :partition_letter, :string
  end
end
