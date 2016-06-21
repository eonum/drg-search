# A NumCase is the number of cases in a certain DRG, MDC, Partition or ADRG for a certain year and hospital
class NumCase < ActiveRecord::Base

  def hospital
    return Hospital.where(hospital_id: self.hospital_id, year: self.year).first
  end

  def code_link
    code_class = {'MDC': Mdc, 'PARTITION': Partition, 'ADRG': Adrg, 'DRG': Drg}[self.level.to_sym]
    return code_class.where(code: self.code, version: self.version).first
  end
end
