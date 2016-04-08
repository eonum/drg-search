class Partition < ActiveRecord::Base
  belongs_to :mdc

  has_many :adrgs
end
