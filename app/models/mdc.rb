class Mdc < ActiveRecord::Base
  has_many :partitions
  has_many :adrgs
end
