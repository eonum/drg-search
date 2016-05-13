class Mdc < ActiveRecord::Base
  has_many :partitions
  has_many :adrgs
  has_many :drgs

  include MultiLanguageText

  def code_display
    return code if code == 'ALL'
    return 'MDC ' + code
  end
end
