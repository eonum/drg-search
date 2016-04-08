class Drg < ActiveRecord::Base
  belongs_to :mdc
  belongs_to :partition
  belongs_to :adrg
end
