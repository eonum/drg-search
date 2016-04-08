class Adrg < ActiveRecord::Base
  belongs_to :mdc
  belongs_to :partition

  has_many :drgs
end
