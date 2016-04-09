class System < ActiveRecord::Base

  def base_year
    return self.years.max
  end
end
