class AddRelevantCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :mdcs, :relevant_codes, :text
    add_column :adrgs, :relevant_codes, :text
    add_column :drgs, :relevant_codes, :text
  end
end
