class Adrg < ActiveRecord::Base
  belongs_to :mdc
  belongs_to :partition
  has_many :drgs

  include MultiLanguageText

  def code_display
    return code
  end
end
