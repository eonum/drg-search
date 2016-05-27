class Adrg < ActiveRecord::Base
  belongs_to :mdc
  belongs_to :partition
  has_many :drgs

  include MultiLanguageText

  searchkick callbacks: false, language: 'german', synonyms: [CSV.read("data/mesh_2016/synonyms.csv")]

  def code_display
    return code
  end

  def generalize
    return self.partition
  end

  def specialize
    return self.drgs.order(code: :asc)
  end
end
