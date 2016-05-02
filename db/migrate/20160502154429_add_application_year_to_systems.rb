class AddApplicationYearToSystems < ActiveRecord::Migration
  def change
    add_column :systems, :application_year, :integer
  end
end
