class AddApplicationYearToSystems < ActiveRecord::Migration[5.2]
  def change
    add_column :systems, :application_year, :integer
  end
end
