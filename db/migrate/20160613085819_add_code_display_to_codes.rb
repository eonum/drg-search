class AddCodeDisplayToCodes < ActiveRecord::Migration
  def change
    add_column :mdcs, :code_search, :string
  end
end
