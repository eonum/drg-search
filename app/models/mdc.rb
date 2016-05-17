class Mdc < ActiveRecord::Base
  has_many :partitions
  has_many :adrgs
  has_many :drgs

  include MultiLanguageText

  def code_display
    return code if code == 'ALL'
    return 'MDC ' + code
  end

  def generalize
    return Mdc.where("version = '#{self.version}' and code = 'ALL'").first unless code == 'ALL'
    return nil
  end

  def specialize
    return Mdc.where("version = '#{self.version}' and code <> 'ALL'").order(code: :asc) if code == 'ALL'
    return self.partitions
  end
end
