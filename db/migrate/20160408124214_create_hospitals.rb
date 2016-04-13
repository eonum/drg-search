class CreateHospitals < ActiveRecord::Migration
  def change
    create_table :hospitals do |t|
      t.integer :year
      t.integer :hospital_id
      t.string :name
      t.string :street
      t.string :address
      t.string :canton
    end
  end
end
