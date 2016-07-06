# A NumCase is the number of cases in a certain DRG, MDC, Partition or ADRG for a certain year and hospital
class NumCase < ActiveRecord::Base
  belongs_to :code_object, polymorphic: true

  def hospital
    return Hospital.where(hospital_id: self.hospital_id, year: self.year).first
  end
end
