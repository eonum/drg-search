class AddRelevantCodesMultiLingual < ActiveRecord::Migration
  def change
    remove_column :mdcs, :relevant_codes
    remove_column :adrgs, :relevant_codes
    remove_column :drgs, :relevant_codes

    add_column :mdcs, :relevant_codes_de, :text
    add_column :adrgs, :relevant_codes_de, :text
    add_column :drgs, :relevant_codes_de, :text

    add_column :mdcs, :relevant_codes_fr, :text
    add_column :adrgs, :relevant_codes_fr, :text
    add_column :drgs, :relevant_codes_fr, :text

    add_column :mdcs, :relevant_codes_it, :text
    add_column :adrgs, :relevant_codes_it, :text
    add_column :drgs, :relevant_codes_it, :text
  end
end
