class Drg < ActiveRecord::Base
  belongs_to :mdc
  belongs_to :partition
  belongs_to :adrg

  include MultiLanguageText

  searchkick callbacks: false, language: 'german'

  def code_display
    return code
  end

  def code_display_long
    return 'DRG ' + code
  end

  def generalize
    return self.adrg
  end

  def specialize
    return nil
  end
end
