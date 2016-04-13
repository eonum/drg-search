class Partition < ActiveRecord::Base
  belongs_to :mdc

  has_many :adrgs
  has_many :drgs

  def partition_letter
    return self.code.split(' ')[1]
  end
end
