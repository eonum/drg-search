class System < ActiveRecord::Base
  validates_uniqueness_of :version

  def base_year
    return self.years.max
  end
end
