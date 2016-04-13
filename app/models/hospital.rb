# A hospital is a representation of a hospital in one year.
# Hence a unique hospital can have multiple hospital objects. One for each year.
class Hospital < ActiveRecord::Base
  has_many :num_cases

  # hospital_id is only unique within one year
  # id is unique over all hospital objects
end
