class System < ActiveRecord::Base
  validates_uniqueness_of :version

  include MultiLanguageText

  def base_year
    return self.years.max
  end
end
