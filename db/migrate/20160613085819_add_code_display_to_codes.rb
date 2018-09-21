class AddCodeDisplayToCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :mdcs, :code_search, :string
  end
end
