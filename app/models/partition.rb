class Partition < ActiveRecord::Base
  belongs_to :mdc

  has_many :adrgs
  has_many :drgs

  def partition_letter
    return self.code.split(' ')[1]
  end

  def code_display
    return 'MDC ' + code
  end

  def generalize
    return self.mdc
  end

  def spezialize
    return self.adrgs.order(code: :asc)
  end
end
