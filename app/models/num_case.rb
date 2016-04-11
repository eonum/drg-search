# A NumCase is the number of cases in a certain DRG, MDC, Partition or ADRG for a certain year and hospital
class NumCase < ActiveRecord::Base
  belongs_to :hospital
end
