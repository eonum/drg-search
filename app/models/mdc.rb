class Mdc < ApplicationRecord
  has_many :partitions
  has_many :adrgs
  has_many :drgs

  include MultiLanguageText

  searchkick word_middle: [:text_de, :text_fr, :text_it], callbacks: false, language: 'german',
             synonyms: -> { CSV.read('data/mesh_2016/synonyms.csv', {col_sep: ';'}) }

  def code_display
    return code if code == 'ALL'
    return 'MDC ' + code
  end

  def code_display_long
    return code_display
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
