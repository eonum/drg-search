class Adrg < ActiveRecord::Base
  belongs_to :mdc
  belongs_to :partition
  has_many :drgs

  include MultiLanguageText

  searchkick callbacks: false, language: 'german'

  def code_display
    return code
  end

  def code_display_long
    return I18n.t('adrg') + ' ' + code
  end

  def generalize
    return self.partition
  end

  def specialize
    return self.drgs.order(code: :asc)
  end
end
