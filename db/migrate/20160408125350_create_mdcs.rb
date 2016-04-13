class CreateMdcs < ActiveRecord::Migration
  def change
    create_table :mdcs do |t|
      t.string :code
      t.string :version
      t.string :text_de
      t.string :text_fr
      t.string :text_it
      t.string :prefix
    end
  end
end
