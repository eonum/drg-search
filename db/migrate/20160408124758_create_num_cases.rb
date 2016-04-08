class CreateNumCases < ActiveRecord::Migration
  def change
    create_table :num_cases do |t|
      t.integer :n
      t.integer :hospital_id
      t.integer :year
      t.string :version
      t.string :level
      t.string :code
    end
  end
end
