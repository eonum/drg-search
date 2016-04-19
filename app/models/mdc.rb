class Mdc < ActiveRecord::Base
  has_many :partitions
  has_many :adrgs
  has_many :drgs

  include MultiLanguageText
end
