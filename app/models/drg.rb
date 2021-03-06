class Drg < ApplicationRecord
  belongs_to :mdc
  belongs_to :partition
  belongs_to :adrg

  include MultiLanguageText

  searchkick word_middle: [:text_de, :text_fr, :text_it],
             callbacks: false, language: 'german', batch_size: 10,
             synonyms: -> { CSV.read('data/mesh_2016/synonyms.csv', {col_sep: ';'}) }

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
